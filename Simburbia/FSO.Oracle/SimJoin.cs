using System;
using FSO.SimAntics;
using FSO.SimAntics.Model.TSOPlatform;
using FSO.SimAntics.NetPlay.Model;
using FSO.SimAntics.NetPlay.Model.Commands;

namespace FSO.Oracle
{
    /// <summary>
    /// Brings made-up Sims onto a lot the way a player joins one: FreeSO's
    /// <c>VMNetSimJoinCmd</c>, as the lot server runs it when an avatar arrives. Each Sim is the
    /// person template, placed by the mailbox (or at tile 3,3 without one), with an identity
    /// defined here rather than any player's or city's data.
    /// </summary>
    /// <remarks>
    /// <para>The identity: Sim <c>n</c> (from 1) is named "Oracle Sim n", has persist ID
    /// <c>0x0AC1E000 + n</c>, joins as a visitor (so FreeSO's roommate bookkeeping doesn't run), is
    /// male with skin tone 0, wears FreeSO's default suits (constants from
    /// <c>VMAvatarDefaultSuits</c>; outfits aren't loaded headless), has every motive at 0 and
    /// every persisted skill at 0, and no relationships, jobs, or budget.</para>
    /// <para>The template: FreeSO's <c>VMAvatar.TEMPLATE_PERSON</c>, a static the join command reads.
    /// MockInstall has no such object, so <c>--sim-template</c> names its made-up Sim instead; the
    /// oracle sets the static before joining. It's the one change, and it's to a static FreeSO left
    /// open, not to any file under <c>TSOClient</c>.</para>
    /// </remarks>
    internal static class SimJoin
    {
        public const uint FirstPersistID = 0x0AC1_E000;

        /// <summary>Joins <paramref name="count"/> Sims, one after another, as their commands would run.</summary>
        public static void Join(VM vm, int count, uint template)
        {
            VMAvatar.TEMPLATE_PERSON = template;
            for (var n = 1; n <= count; n++)
            {
                var persistID = FirstPersistID + (uint)n;
                var state = new VMNetAvatarPersistState
                {
                    Name = $"Oracle Sim {n}",
                    PersistID = persistID,
                    DefaultSuits = new VMAvatarDefaultSuits(false),
                    Permissions = VMTSOAvatarPermissions.Visitor,
                    Budget = 0,
                    SkinTone = 0,
                    Gender = 0,
                };
                state.BodyOutfit = state.DefaultSuits.Daywear.ID;
                state.HeadOutfit = 0;
                var command = new VMNetSimJoinCmd { ActorUID = persistID, AvatarState = state };
                if (!command.Execute(vm)) throw new InvalidOperationException($"FreeSO refused to join Sim {n}");
            }
        }
    }
}
