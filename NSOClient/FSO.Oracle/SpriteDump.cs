using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using FSO.Files.FAR1;
using FSO.Files.Formats.IFF;
using FSO.Files.Formats.IFF.Chunks;

namespace FSO.Oracle
{
    /// <summary>
    /// <c>sprites</c>: every object sprite in the install, decoded by FreeSO's own readers.
    ///
    /// FreeSO's content only loads sprites when there's a graphics device, so this opens the
    /// sprite archives itself: each <c>objspf*.far</c> under the install, as TSO's FAR 1b. For each
    /// IFF in them, in name order, it prints one line per <c>SPR2</c> and <c>SPR#</c> frame and one
    /// per <c>DGRP</c>, each keyed by entry, chunk type, chunk ID, and frame (<c>-</c> for a DGRP):
    ///
    /// <c>SPR2</c>: width, height, x, y, palette, flags, then FNV-1a 64 hashes of the RGBA and the
    /// depth bytes (<c>-</c> when the frame has none). <c>SPR#</c>: width, height, palette, and the
    /// RGBA hash. <c>DGRP</c>: version, image count, and the hash of a listing of its images
    /// (see <see cref="DrawGroupListing"/>). A frame or chunk that throws prints <c>error</c> and
    /// the exception's type.
    /// </summary>
    internal static class SpriteDump
    {
        public static void Run(string gameDirectory, TextWriter results)
        {
            var archives = Directory.GetFiles(gameDirectory, "*", SearchOption.AllDirectories)
                .Select(path => Path.GetRelativePath(gameDirectory, path).Replace('\\', '/'))
                .Where(path => Path.GetFileName(path).ToLowerInvariant() is var name && name.StartsWith("objspf") && name.EndsWith(".far"))
                .OrderBy(path => path.ToLowerInvariant(), StringComparer.Ordinal);
            foreach (var archivePath in archives)
            {
                var archive = new FAR1Archive(Path.Combine(gameDirectory, archivePath), true);
                var entries = archive.GetAllEntries().OrderBy(entry => entry.Key.ToLowerInvariant(), StringComparer.Ordinal);
                foreach (var entry in entries)
                {
                    var name = $"{archivePath.ToLowerInvariant()}/{entry.Key.ToLowerInvariant()}";
                    IffFile iff;
                    try
                    {
                        iff = new IffFile();
                        iff.Read(new MemoryStream(entry.Value));
                    }
                    catch (Exception error)
                    {
                        results.WriteLine($"{name}\tIFF\t-\t-\terror\t{error.GetType().Name}");
                        continue;
                    }
                    Sprites2(iff, name, results);
                    Sprites1(iff, name, results);
                    DrawGroups(iff, name, results);
                }
                archive.Close();
            }
        }

        private static void Sprites2(IffFile iff, string name, TextWriter results)
        {
            foreach (var sprite in (iff.List<SPR2>() ?? new List<SPR2>()).OrderBy(chunk => chunk.ChunkID))
            {
                var frames = sprite.Frames ?? new SPR2Frame[0];
                for (var index = 0; index < frames.Length; index++)
                {
                    var key = $"{name}\tSPR2\t{sprite.ChunkID}\t{index}";
                    try
                    {
                        var frame = frames[index];
                        frame.DecodeIfRequired(false);
                        string rgba = "-";
                        if (frame.PixelData != null)
                        {
                            var bytes = new byte[frame.PixelData.Length * 4];
                            for (var i = 0; i < frame.PixelData.Length; i++)
                            {
                                var color = frame.PixelData[i];
                                bytes[i * 4] = color.R;
                                bytes[i * 4 + 1] = color.G;
                                bytes[i * 4 + 2] = color.B;
                                bytes[i * 4 + 3] = color.A;
                            }
                            rgba = Hash(bytes);
                        }
                        var depth = frame.ZBufferData == null ? "-" : Hash(frame.ZBufferData);
                        results.WriteLine(string.Join("\t", key, frame.Width, frame.Height, (int)frame.Position.X, (int)frame.Position.Y,
                            frame.PaletteID, frame.Flags, rgba, depth));
                    }
                    catch (Exception error)
                    {
                        results.WriteLine($"{key}\terror\t{error.GetType().Name}");
                    }
                }
            }
        }

        private static void Sprites1(IffFile iff, string name, TextWriter results)
        {
            foreach (var sprite in (iff.List<SPR>() ?? new List<SPR>()).OrderBy(chunk => chunk.ChunkID))
            {
                var frames = sprite.Frames ?? new List<SPRFrame>();
                for (var index = 0; index < frames.Count; index++)
                {
                    var key = $"{name}\tSPR#\t{sprite.ChunkID}\t{index}";
                    try
                    {
                        var frame = frames[index];
                        frame.DecodeIfRequired();
                        var bytes = new byte[frame.Width * frame.Height * 4];
                        for (var y = 0; y < frame.Height; y++)
                        {
                            for (var x = 0; x < frame.Width; x++)
                            {
                                var color = frame.GetPixel(x, y);
                                var at = (y * frame.Width + x) * 4;
                                bytes[at] = color.R;
                                bytes[at + 1] = color.G;
                                bytes[at + 2] = color.B;
                                bytes[at + 3] = color.A;
                            }
                        }
                        results.WriteLine(string.Join("\t", key, frame.Width, frame.Height, sprite.PaletteID, Hash(bytes)));
                    }
                    catch (Exception error)
                    {
                        results.WriteLine($"{key}\terror\t{error.GetType().Name}");
                    }
                }
            }
        }

        private static void DrawGroups(IffFile iff, string name, TextWriter results)
        {
            foreach (var group in (iff.List<DGRP>() ?? new List<DGRP>()).OrderBy(chunk => chunk.ChunkID))
            {
                var key = $"{name}\tDGRP\t{group.ChunkID}\t-";
                try
                {
                    var listing = DrawGroupListing(group);
                    results.WriteLine(string.Join("\t", key, group.Images.Length, Hash(Encoding.UTF8.GetBytes(listing))));
                }
                catch (Exception error)
                {
                    results.WriteLine($"{key}\terror\t{error.GetType().Name}");
                }
            }
        }

        /// <summary>
        /// A drawing group's images as text, which <c>nso-oracle</c> writes the same way: each image as
        /// <c>direction,zoom:</c> and its sprites, each as <c>id,frame,flags,x,y</c> and the object
        /// offset's x, y, and z as their bit patterns in hex, separated by <c>;</c>; images by <c>|</c>.
        /// </summary>
        private static string DrawGroupListing(DGRP group)
        {
            return string.Join("|", group.Images.Select(image =>
                $"{image.Direction},{image.Zoom}:" + string.Join(";", image.Sprites.Select(sprite =>
                    string.Join(",", sprite.SpriteID, sprite.SpriteFrameIndex, (uint)sprite.Flags,
                        (int)sprite.SpriteOffset.X, (int)sprite.SpriteOffset.Y,
                        Bits(sprite.ObjectOffset.X), Bits(sprite.ObjectOffset.Y), Bits(sprite.ObjectOffset.Z))))));
        }

        private static string Bits(float value) => BitConverter.SingleToInt32Bits(value).ToString("x8");

        /// <summary>FNV-1a, 64 bits, as 16 hex digits.</summary>
        private static string Hash(byte[] bytes)
        {
            ulong hash = 14695981039346656037;
            foreach (var b in bytes)
            {
                hash ^= b;
                hash *= 1099511628211;
            }
            return hash.ToString("x16");
        }
    }
}
