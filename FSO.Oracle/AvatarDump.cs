using System;
using System.Globalization;
using System.IO;
using System.Linq;
using FSO.Files.FAR3;
using FSO.Vitaboy;
using Microsoft.Xna.Framework;

namespace FSO.Oracle
{
    /// <summary>
    /// <c>avatars</c>: every file in the install's avatar archives (<c>avatardata/**/*.dat</c>, FAR 3),
    /// decoded by FreeSO's own Vitaboy readers.
    ///
    /// FreeSO's content leaves meshes, textures, and hand groups out without a graphics device, as
    /// the headless oracle runs it, so this opens the archives itself. Each line is the archive, the
    /// entry's name, type ID, and file ID (hexadecimal), then what was read:
    ///
    /// <c>skel</c>: bone count, then each bone as <c>NAME&lt;PARENT</c>. <c>mesh</c>: bones, faces, real and
    /// blend vertices, and the real vertices' bounds once skinned on the install's <c>adult.skel</c>
    /// (FreeSO's <c>ComputeBonePositions</c>, each vertex by its bone's absolute matrix), as
    /// <c>min x,y,z max x,y,z</c>. <c>bnd</c>: bone, mesh file and type, texture file and type. <c>apr</c>: each
    /// binding's file and type. <c>oft</c>: the light, medium, and dark appearances, the hand group,
    /// and the region. <c>hag</c>: the light right hand's idle gesture and the dark left hand's
    /// fist, first and last. <c>anim</c>: name, duration, distance, moving, and each motion's bone and
    /// frame count. Textures and thumbnails: byte count and the first two bytes. An entry that
    /// throws prints <c>error</c> and the exception's type.
    /// </summary>
    internal static class AvatarDump
    {
        /// <summary>A mesh's face indices, which FreeSO keeps protected (<c>Mesh.IndexBuffer</c>).</summary>
        private static readonly System.Reflection.FieldInfo IndexBufferField =
            typeof(Mesh).GetField("IndexBuffer", System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic)
            ?? throw new InvalidOperationException("Mesh.IndexBuffer not found; the snapshot's sources changed");

        public static void Run(string gameDirectory, TextWriter results)
        {
            var archives = Directory.GetFiles(Path.Combine(gameDirectory, "avatardata"), "*.dat", SearchOption.AllDirectories)
                .Select(path => Path.GetRelativePath(gameDirectory, path).Replace('\\', '/'))
                .OrderBy(path => path.ToLowerInvariant(), StringComparer.Ordinal).ToList();
            Skeleton adult = null;
            foreach (var archivePath in archives.Where(path => path.Contains("/skeletons/")))
            {
                var archive = new FAR3Archive(Path.Combine(gameDirectory, archivePath));
                var entry = archive.GetAllFAR3Entries().FirstOrDefault(e => e.Filename.ToLowerInvariant() == "adult.skel");
                if (entry == null) continue;
                adult = new Skeleton();
                adult.Read(new MemoryStream(archive.GetEntry(entry)), false);
                adult.ComputeBonePositions(adult.RootBone, Matrix.Identity);
            }
            foreach (var archivePath in archives)
            {
                FAR3Archive archive;
                try
                {
                    archive = new FAR3Archive(Path.Combine(gameDirectory, archivePath));
                }
                catch (Exception error)
                {
                    results.WriteLine($"{archivePath}\t-\t-\t-\terror\t{error.GetType().Name}");
                    continue;
                }
                foreach (var entry in archive.GetAllFAR3Entries().OrderBy(e => e.FileID).ThenBy(e => e.TypeID))
                {
                    var key = $"{archivePath}\t{entry.Filename}\t{entry.TypeID}\t{entry.FileID:x8}";
                    try
                    {
                        results.WriteLine($"{key}\t{Describe(entry.Filename, archive.GetEntry(entry), adult)}");
                    }
                    catch (Exception error)
                    {
                        results.WriteLine($"{key}\terror\t{error.GetType().Name}: {error.Message}");
                    }
                }
            }
        }

        private static string F(float value) => value.ToString("0.###", CultureInfo.InvariantCulture);

        private static string Describe(string name, byte[] data, Skeleton adult)
        {
            var stream = new MemoryStream(data);
            switch (Path.GetExtension(name).ToLowerInvariant())
            {
                case ".skel":
                    var skeleton = new Skeleton();
                    skeleton.Read(stream, false);
                    return $"skel\t{skeleton.Bones.Length}\t{string.Join(" ", skeleton.Bones.Select(b => $"{b.Name}<{b.ParentName}"))}";
                case ".mesh":
                    var mesh = new Mesh();
                    mesh.Read(stream, false);
                    var bounds = "-";
                    if (adult != null)
                    {
                        var min = new Vector3(float.MaxValue); var max = new Vector3(float.MinValue);
                        foreach (var binding in mesh.BoneBindings)
                        {
                            var bone = adult.GetBone(binding.BoneName);
                            if (bone == null) continue;
                            for (var i = binding.FirstRealVertex; i < binding.FirstRealVertex + binding.RealVertexCount; i++)
                            {
                                var position = Vector3.Transform(mesh.VertexBuffer[i].Position, bone.AbsoluteMatrix);
                                min = Vector3.Min(min, position); max = Vector3.Max(max, position);
                            }
                        }
                        if (min.X <= max.X) bounds = $"{F(min.X)},{F(min.Y)},{F(min.Z)} {F(max.X)},{F(max.Y)},{F(max.Z)}";
                    }
                    return $"mesh\t{mesh.BoneBindings.Length}\t{((short[])IndexBufferField.GetValue(mesh)).Length / 3}\t{mesh.VertexBuffer.Length}\t{mesh.BlendData.Length}\t{bounds}";
                case ".bnd":
                    var bnd = new Binding();
                    bnd.Read(stream);
                    return $"bnd\t{bnd.Bone}\t{bnd.MeshFileID:x8}:{bnd.MeshTypeID}\t{bnd.TextureFileID:x8}:{bnd.TextureTypeID}";
                case ".apr":
                    var apr = new Appearance();
                    apr.Read(stream);
                    return $"apr\t{string.Join(" ", apr.Bindings.Select(b => $"{b.FileID:x8}:{b.TypeID}"))}";
                case ".oft":
                    var oft = new Outfit();
                    oft.Read(stream);
                    return $"oft\t{oft.LightAppearanceFileID:x8}:{oft.LightAppearanceTypeID}\t{oft.MediumAppearanceFileID:x8}:{oft.MediumAppearanceTypeID}"
                        + $"\t{oft.DarkAppearanceFileID:x8}:{oft.DarkAppearanceTypeID}\t{oft.HandGroup:x8}\t{oft.Region}";
                case ".hag":
                    var hag = new HandGroup();
                    hag.Read(stream);
                    return $"hag\t{hag.LightSkin.RightHand.Idle.FileID:x8}:{hag.LightSkin.RightHand.Idle.TypeID}"
                        + $"\t{hag.DarkSkin.LeftHand.Fist.FileID:x8}:{hag.DarkSkin.LeftHand.Fist.TypeID}";
                case ".anim":
                    var anim = new Animation();
                    anim.Read(stream, false);
                    return $"anim\t{anim.Name}\t{F(anim.Duration)}\t{F(anim.Distance)}\t{anim.IsMoving}"
                        + $"\t{string.Join(" ", anim.Motions.Select(m => $"{m.BoneName}:{m.FrameCount}"))}";
                default:
                    return $"bytes\t{data.Length}\t{(data.Length >= 2 ? $"{data[0]:x2}{data[1]:x2}" : "-")}";
            }
        }
    }
}
