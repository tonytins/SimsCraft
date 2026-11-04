using System;
using System.IO;
using System.Linq;
using FSO.Files.Formats.IFF;

namespace FSO.Oracle
{
    /// <summary>
    /// <c>architecture</c>: which sprite chunks FreeSO's wall and floor providers find for each ID,
    /// read through <c>Content.WorldWalls</c> and <c>Content.WorldFloors</c> as the lot view asks
    /// them. One tab-separated line each:
    ///
    /// <list type="bullet">
    /// <item><c>floor ID FILE FAR MEDIUM NEAR PIXELS</c> for each floor catalog entry, in ID order.</item>
    /// <item><c>floor-sprite ID SPRITE PIXELS</c> for each pool (0x400 to 0x43F) and water (0x800 to
    /// 0x80F) sprite <c>GetGlobalSPR</c> finds.</item>
    /// <item><c>wall ID FILE FAR MEDIUM NEAR</c> for patterns 0 to 255 and each archive pattern.</item>
    /// <item><c>style ID UP-FAR UP-MEDIUM UP-NEAR DOWN-FAR DOWN-MEDIUM DOWN-NEAR</c> for styles 1 to 255.</item>
    /// <item><c>junctions - FAR MEDIUM NEAR</c>.</item>
    /// </list>
    ///
    /// A sprite is <c>-</c> when there's none, else its chunk ID and frame count (<c>1537:4</c>).
    /// FILE is the catalog entry's file name, <c>global</c> for a global one. PIXELS lists each frame
    /// of the floor's sprites, far to near, as FreeSO decodes it for drawing (its sprite's
    /// <c>FloorCopy</c> and <c>ZAsAlpha</c> set as the providers set them): the size, then the FNV-1a 64
    /// hash of its RGBA (<c>128x64:0123abcd...</c>), comma-separated, or <c>-</c> with no frames. An ID that throws
    /// prints <c>error</c> and the exception's type. Catalog names and prices aren't printed:
    /// Simburbia reads some from other strings on purpose (DIFF-29).
    /// </summary>
    internal static class ArchitectureDump
    {
        public static void Run(TextWriter results)
        {
            var content = Content.Content.Get();
            var floors = content.WorldFloors;
            foreach (var id in floors.Entries.Keys.OrderBy(id => id))
            {
                Line(results, $"floor\t{id}", () =>
                {
                    var floor = floors.Get(id);
                    var file = floors.Entries[id].FileName;
                    return floor == null ? $"{file}\t-\t-\t-\t-"
                        : $"{file}\t{Sprite(floor.Far)}\t{Sprite(floor.Medium)}\t{Sprite(floor.Near)}\t{Pixels(floor.Far, floor.Medium, floor.Near)}";
                });
            }
            foreach (var id in Enumerable.Range(0x400, 0x40).Concat(Enumerable.Range(0x800, 0x10)))
            {
                // GetGlobalSPR dereferences what it finds, so a sprite that isn't there throws.
                Files.Formats.IFF.Chunks.SPR2 sprite;
                try { sprite = floors.GetGlobalSPR((ushort)id); }
                catch (NullReferenceException) { continue; }
                results.WriteLine($"floor-sprite\t{id}\t{Sprite(sprite)}\t{Pixels(sprite)}");
            }

            var walls = content.WorldWalls;
            var patterns = Enumerable.Range(0, 256).Select(id => (ushort)id)
                .Concat(walls.Entries.Keys.Where(id => id >= 256).OrderBy(id => id));
            foreach (var id in patterns)
            {
                Line(results, $"wall\t{id}", () =>
                {
                    var wall = walls.Get(id);
                    var file = id < 256 ? "global" : walls.Entries[id].FileName;
                    return wall == null ? $"{file}\t-\t-\t-" : $"{file}\t{Sprite(wall.Far)}\t{Sprite(wall.Medium)}\t{Sprite(wall.Near)}";
                });
            }
            for (ushort id = 1; id < 256; id++)
            {
                var styleID = id;
                Line(results, $"style\t{id}", () =>
                {
                    var style = walls.GetWallStyle(styleID);
                    return style == null ? "-\t-\t-\t-\t-\t-" : string.Join("\t",
                        Sprite(style.WallsUpFar), Sprite(style.WallsUpMedium), Sprite(style.WallsUpNear),
                        Sprite(style.WallsDownFar), Sprite(style.WallsDownMedium), Sprite(style.WallsDownNear));
                });
            }
            Line(results, "junctions\t-", () =>
                $"{Sprite(walls.Junctions.Far)}\t{Sprite(walls.Junctions.Medium)}\t{Sprite(walls.Junctions.Near)}");
        }

        private static void Line(TextWriter results, string key, Func<string> record)
        {
            string line;
            try
            {
                line = record();
            }
            catch (Exception error)
            {
                line = "error\t" + error.GetType().Name;
                Console.Error.WriteLine($"fso-oracle: architecture {key.Replace('\t', ' ')}: {error}");
            }
            results.WriteLine($"{key}\t{line}");
        }

        /// <summary>Each frame of the sprites, decoded as FreeSO decodes them to draw.</summary>
        private static string Pixels(params Files.Formats.IFF.Chunks.SPR2[] sprites)
        {
            var frames = sprites.Where(sprite => sprite?.Frames != null).SelectMany(sprite => sprite.Frames).Select(frame =>
            {
                try
                {
                    frame.DecodeIfRequired(false);
                    if (frame.PixelData == null) return $"{frame.Width}x{frame.Height}:-";
                    var bytes = new byte[frame.PixelData.Length * 4];
                    for (var i = 0; i < frame.PixelData.Length; i++)
                    {
                        var color = frame.PixelData[i];
                        bytes[i * 4] = color.R;
                        bytes[i * 4 + 1] = color.G;
                        bytes[i * 4 + 2] = color.B;
                        bytes[i * 4 + 3] = color.A;
                    }
                    return $"{frame.Width}x{frame.Height}:{SpriteDump.Hash(bytes)}";
                }
                catch (Exception error)
                {
                    return "error:" + error.GetType().Name;
                }
            }).ToList();
            return frames.Count == 0 ? "-" : string.Join(",", frames);
        }

        private static string Sprite(IffChunk sprite) => sprite switch
        {
            null => "-",
            Files.Formats.IFF.Chunks.SPR2 spr2 => $"{spr2.ChunkID}:{spr2.Frames?.Length ?? 0}",
            Files.Formats.IFF.Chunks.SPR spr => $"{spr.ChunkID}:{spr.Frames?.Count ?? 0}",
            _ => $"{sprite.ChunkID}:?",
        };
    }
}
