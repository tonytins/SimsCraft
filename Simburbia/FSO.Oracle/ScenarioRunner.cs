using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using FSO.SimAntics;

namespace FSO.Oracle
{
    /// <summary>
    /// FreeSO's side of sso-oracle's scenarios: SimsScript objects compiled by
    /// <c>sso-oracle build</c>, run as <c>run-objects</c> runs an object, with their attributes
    /// printed by name.
    /// </summary>
    public static class ScenarioRunner
    {
        /// <summary>
        /// A temporary content folder: links to everything in FreeSO's, with the scenario objects
        /// added to its <c>Objects</c> folder, where FreeSO loads standalone objects from.
        /// </summary>
        public sealed class ContentOverlay : IDisposable
        {
            public string Path { get; }

            public ContentOverlay(string contentDirectory, string scenarioDirectory)
            {
                Path = System.IO.Path.Combine(System.IO.Path.GetTempPath(), "fso-oracle-content-" + Guid.NewGuid().ToString("N")) + "/";
                Directory.CreateDirectory(Path);
                foreach (var entry in Directory.GetFileSystemEntries(contentDirectory))
                {
                    var name = System.IO.Path.GetFileName(entry.TrimEnd('/'));
                    if (name == "Objects") continue;
                    var link = System.IO.Path.Combine(Path, name);
                    if (Directory.Exists(entry)) Directory.CreateSymbolicLink(link, entry);
                    else File.CreateSymbolicLink(link, entry);
                }
                var objects = System.IO.Path.Combine(Path, "Objects");
                Directory.CreateDirectory(objects);
                var ownObjects = System.IO.Path.Combine(contentDirectory, "Objects");
                if (Directory.Exists(ownObjects))
                {
                    foreach (var entry in Directory.GetFileSystemEntries(ownObjects))
                    {
                        var link = System.IO.Path.Combine(objects, System.IO.Path.GetFileName(entry));
                        if (Directory.Exists(entry)) Directory.CreateSymbolicLink(link, entry);
                        else File.CreateSymbolicLink(link, entry);
                    }
                }
                var scenarios = System.IO.Path.Combine(objects, "sso-scenarios");
                Directory.CreateDirectory(scenarios);
                foreach (var file in Directory.GetFiles(scenarioDirectory, "*.iff"))
                    File.CreateSymbolicLink(System.IO.Path.Combine(scenarios, System.IO.Path.GetFileName(file)), System.IO.Path.GetFullPath(file));
            }

            public void Dispose()
            {
                try { Directory.Delete(Path, true); }
                catch (IOException) { }
            }
        }

        /// <summary>One line of <c>scenarios.tsv</c>.</summary>
        public sealed class Entry
        {
            public uint GUID;
            public string Name;
            public int Ticks;
            public string[] Attributes;
        }

        /// <summary>
        /// Reads <c>scenarios.tsv</c>: GUID (hexadecimal), name, ticks, and the attribute names,
        /// comma-separated.
        /// </summary>
        public static List<Entry> ReadTable(string scenarioDirectory)
        {
            var entries = new List<Entry>();
            var path = Path.Combine(scenarioDirectory, "scenarios.tsv");
            foreach (var line in File.ReadAllLines(path))
            {
                if (line.Trim().Length == 0) continue;
                var fields = line.Split('\t');
                if (fields.Length != 4
                    || !uint.TryParse(fields[0], System.Globalization.NumberStyles.HexNumber, null, out var guid)
                    || !int.TryParse(fields[2], out var ticks) || ticks < 0)
                    throw new ArgumentException($"{path}: can't read the line \"{line}\"");
                entries.Add(new Entry
                {
                    GUID = guid,
                    Name = fields[1],
                    Ticks = ticks,
                    Attributes = fields[3].Length == 0 ? Array.Empty<string>() : fields[3].Split(','),
                });
            }
            return entries;
        }

        /// <summary>
        /// Runs each scenario on a fresh empty lot: the object created out of the world as
        /// <c>VMContext.CreateObjectInstance</c> does (running its init), then its ticks. Prints
        /// <c>name guid attributes a=1 b=2</c>, the form <c>sso-oracle run --records-only</c>
        /// prints; or <c>name guid missing</c>, or <c>name guid error Type</c> if creating or
        /// ticking throws. FreeSO suppresses an exception inside a thread and resets the object,
        /// so those don't show here.
        /// </summary>
        public static void Run(List<Entry> entries, Func<VM> emptyLot, TextWriter results)
        {
            foreach (var entry in entries)
            {
                var prefix = $"{entry.Name} {entry.GUID:x8}";
                try
                {
                    var vm = emptyLot();
                    var group = vm.Context.CreateObjectInstance(entry.GUID, FSO.LotView.Model.LotTilePos.OUT_OF_WORLD, FSO.LotView.Model.Direction.NORTH);
                    var entity = group?.Objects.FirstOrDefault();
                    if (entity == null)
                    {
                        results.WriteLine($"{prefix} missing");
                        continue;
                    }
                    for (var tick = 0; tick < entry.Ticks; tick++) vm.Tick();
                    var values = entry.Attributes.Select((name, index) => $"{name}={entity.GetAttribute(index)}");
                    results.WriteLine($"{prefix} attributes {string.Join(" ", values)}");
                }
                catch (Exception error)
                {
                    results.WriteLine($"{prefix} error {error.GetType().Name}");
                    Console.Error.WriteLine($"fso-oracle: scenario {entry.Name}: {error}");
                }
                results.Flush();
            }
        }
    }
}
