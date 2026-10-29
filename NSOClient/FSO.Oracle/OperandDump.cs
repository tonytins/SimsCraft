using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using FSO.Files.FAR1;
using FSO.Files.Formats.IFF;
using FSO.Files.Formats.IFF.Chunks;
using FSO.SimAntics;
using FSO.SimAntics.Engine;

namespace FSO.Oracle
{
    /// <summary>
    /// <c>operands</c>: the operands of primitives NSOClient decodes but doesn't run yet, as
    /// FreeSO's own operand classes read them.
    ///
    /// For each IFF in the install's <c>objiff.far</c> and global folder, in name order, and each
    /// <c>BHAV</c> in it, every instruction whose opcode is in <see cref="Opcodes"/> is read with
    /// the operand class FreeSO registers for it in TSO mode. It prints the entry, the BHAV ID,
    /// the instruction index, the opcode, and every public field and property of the operand
    /// that holds a number, enum, or boolean, as <c>Name=value</c> pairs in name order
    /// (enums as their numbers, booleans as 0 or 1). An operand that throws prints <c>error</c>
    /// and the exception's type; a BHAV that can't be read prints <c>-</c> for its index.
    /// </summary>
    internal static class OperandDump
    {
        /// <summary>Opcodes NSOClient decodes without running (its <c>PrimitiveTable.unportedOperands</c>).</summary>
        private static readonly HashSet<ushort> Opcodes = new HashSet<ushort>
        {
            1, 4, 5, 6, 9, 13, 14, 20, 22, 24, 26, 27, 29, 30, 36, 37, 38, 39, 40, 43, 44, 45, 46, 47, 50, 62, 65, 67,
        };

        public static void Run(string gameDirectory, TextWriter results)
        {
            VM.UseWorld = false;
            var registrations = new VMContext(null).Primitives;
            foreach (var (name, iff) in Files(gameDirectory, results))
            {
                var ids = iff.SilentListAll().OfType<BHAV>().Select(chunk => chunk.ChunkID).OrderBy(id => id).ToList();
                foreach (var id in ids)
                {
                    BHAV routine;
                    try
                    {
                        routine = iff.Get<BHAV>(id);
                    }
                    catch (Exception error)
                    {
                        results.WriteLine($"{name}\t{id}\t-\t-\terror\t{error.GetType().Name}");
                        continue;
                    }
                    for (var index = 0; index < routine.Instructions.Length; index++)
                    {
                        var instruction = routine.Instructions[index];
                        if (!Opcodes.Contains(instruction.Opcode) || registrations[instruction.Opcode]?.OperandModel == null) continue;
                        var prefix = $"{name}\t{id}\t{index}\t{instruction.Opcode}";
                        try
                        {
                            var operand = (VMPrimitiveOperand)Activator.CreateInstance(registrations[instruction.Opcode].OperandModel);
                            operand.Read(instruction.Operand);
                            results.WriteLine($"{prefix}\t{Fields(operand)}");
                        }
                        catch (Exception error)
                        {
                            results.WriteLine($"{prefix}\terror\t{error.GetType().Name}");
                        }
                    }
                }
            }
        }

        /// <summary>The IFFs: each entry of <c>objectdata/objects/objiff.far</c>, then each <c>.iff</c> in <c>objectdata/globals</c>.</summary>
        private static IEnumerable<(string Name, IffFile File)> Files(string gameDirectory, TextWriter results)
        {
            var archivePath = Directory.GetFiles(gameDirectory, "*", SearchOption.AllDirectories)
                .FirstOrDefault(path => Path.GetRelativePath(gameDirectory, path).Replace('\\', '/').ToLowerInvariant() == "objectdata/objects/objiff.far");
            if (archivePath != null)
            {
                var archive = new FAR1Archive(archivePath, true);
                foreach (var entry in archive.GetAllEntries().OrderBy(entry => entry.Key.ToLowerInvariant(), StringComparer.Ordinal))
                {
                    var file = Read(entry.Value, "objiff.far/" + entry.Key.ToLowerInvariant(), results);
                    if (file != null) yield return ("objiff.far/" + entry.Key.ToLowerInvariant(), file);
                }
                archive.Close();
            }
            var globals = Directory.GetDirectories(gameDirectory, "*", SearchOption.AllDirectories)
                .FirstOrDefault(path => Path.GetRelativePath(gameDirectory, path).Replace('\\', '/').ToLowerInvariant() == "objectdata/globals");
            if (globals == null) yield break;
            foreach (var path in Directory.GetFiles(globals).Where(path => path.ToLowerInvariant().EndsWith(".iff"))
                         .OrderBy(path => Path.GetFileName(path).ToLowerInvariant(), StringComparer.Ordinal))
            {
                var name = "globals/" + Path.GetFileName(path).ToLowerInvariant();
                var file = Read(File.ReadAllBytes(path), name, results);
                if (file != null) yield return (name, file);
            }
        }

        private static IffFile Read(byte[] bytes, string name, TextWriter results)
        {
            try
            {
                var iff = new IffFile();
                iff.Read(new MemoryStream(bytes));
                return iff;
            }
            catch (Exception error)
            {
                results.WriteLine($"{name}\t-\t-\t-\terror\t{error.GetType().Name}");
                return null;
            }
        }

        /// <summary>The operand's numeric, enum, and boolean fields and properties, as <c>Name=value</c> in name order.</summary>
        private static string Fields(object operand)
        {
            var values = new SortedDictionary<string, long>(StringComparer.Ordinal);
            var type = operand.GetType();
            foreach (var field in type.GetFields(System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Instance))
                if (Number(field.GetValue(operand)) is long value) values[field.Name] = value;
            foreach (var property in type.GetProperties(System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Instance))
            {
                if (!property.CanRead || property.GetIndexParameters().Length > 0) continue;
                if (Number(property.GetValue(operand)) is long value) values[property.Name] = value;
            }
            return string.Join(";", values.Select(pair => $"{pair.Key}={pair.Value}"));
        }

        private static long? Number(object value) => value switch
        {
            bool flag => flag ? 1 : 0,
            Enum => Convert.ToInt64(value),
            byte or sbyte or short or ushort or int or uint or long => Convert.ToInt64(value),
            _ => null,
        };
    }
}
