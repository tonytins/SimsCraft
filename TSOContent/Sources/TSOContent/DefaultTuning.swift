import Foundation
import TSOFiles

extension GameContent {
    /// Simburbia's default global tuning: `Tuning/tuning.xml`, kept here word for word
    /// so the libraries need no resource bundle (a test checks the two match). Edit the file,
    /// then copy it here.
    public static let defaultTuningXML = #"""
<?xml version="1.0" encoding="UTF-8"?>
<!--
  Simburbia's default global tuning, written for Simburbia (not taken from any TSO install).

  An install's tuning.dat is laid over these key by key, so only what the install lacks comes
  from here: on 1.1097.1.0 nothing does, while the unpatched 2002 and beta discs take all of it,
  since patches delivered their motive tuning. The motive code reads these keys as FreeSO's
  VMAvatarMotiveDecay does: each value times 1000, truncated to a whole number.

  Edit freely to rebalance; see TSOFiles' TuningXML for the format.
-->
<Tuning version="1">
  <!-- Points lost a game minute at weight 1, before the lot's weight. -->
  <Entry name="SimMotives">
    <!-- Hunger's loss a minute is this, in thousandths, times 100 plus Hunger: 0.2 a minute when full, slowing as it drops -->
    <Value key="HungerDecrementRatio">0.0015</Value>
    <Value key="ComfortDecrementActive">0.5</Value>
    <Value key="HygieneDecrementAwake">0.25</Value>
    <Value key="HygieneDecrementAsleep">0.15</Value>
    <Value key="BladderDecrementAwake">0.25</Value>
    <Value key="BladderDecrementAsleep">0.15</Value>
    <!-- the share of Hunger's loss that Bladder loses too -->
    <Value key="HungerToBladderMultiplier">0.2</Value>
    <!-- Energy's whole range, spent over the waking hours: empty after 16 hours awake -->
    <Value key="EnergySpan">200</Value>
    <Value key="WakeHours">16</Value>
    <!-- Fun; a sleeping Sim loses none -->
    <Value key="EntDecrementAwake">0.3</Value>
    <Value key="SocialDecrementBase">0.15</Value>
    <!-- times 100 plus Social, then by the weight; the sum is halved -->
    <Value key="SocialDecrementMultiplier">0.001</Value>
  </Entry>
  <!--
    Each lot category's weight for each motive: a base per motive (Hunger 1, Comfort 0.5,
    Hygiene 0.5, Bladder 1, Energy 2, Fun 0.5, Social 2) times the category's difficulty, from
    TSO Mania's property category guide: easy 0.8, average 1, hard 1.25. Decay is multiplied by
    the weight, and Set Motive Deltas' gains divided by it (except Comfort's), so a hard lot
    drains faster and fills slower. Energy's weight only scales gains.
  -->
  <Entry name="LotMotives">
    <!-- None: average -->
    <Value key="None_HungerWeight">1</Value>
    <Value key="None_ComfortWeight">0.5</Value>
    <Value key="None_HygieneWeight">0.5</Value>
    <Value key="None_BladderWeight">1</Value>
    <Value key="None_EnergyWeight">2</Value>
    <Value key="None_FunWeight">0.5</Value>
    <Value key="None_SocialWeight">2</Value>
    <!-- Money: hard -->
    <Value key="Money_HungerWeight">1.25</Value>
    <Value key="Money_ComfortWeight">0.625</Value>
    <Value key="Money_HygieneWeight">0.625</Value>
    <Value key="Money_BladderWeight">1.25</Value>
    <Value key="Money_EnergyWeight">2.5</Value>
    <Value key="Money_FunWeight">0.625</Value>
    <Value key="Money_SocialWeight">2.5</Value>
    <!-- Offbeat: easy -->
    <Value key="Offbeat_HungerWeight">0.8</Value>
    <Value key="Offbeat_ComfortWeight">0.4</Value>
    <Value key="Offbeat_HygieneWeight">0.4</Value>
    <Value key="Offbeat_BladderWeight">0.8</Value>
    <Value key="Offbeat_EnergyWeight">1.6</Value>
    <Value key="Offbeat_FunWeight">0.4</Value>
    <Value key="Offbeat_SocialWeight">1.6</Value>
    <!-- Romance: easy -->
    <Value key="Romance_HungerWeight">0.8</Value>
    <Value key="Romance_ComfortWeight">0.4</Value>
    <Value key="Romance_HygieneWeight">0.4</Value>
    <Value key="Romance_BladderWeight">0.8</Value>
    <Value key="Romance_EnergyWeight">1.6</Value>
    <Value key="Romance_FunWeight">0.4</Value>
    <Value key="Romance_SocialWeight">1.6</Value>
    <!-- Services: average -->
    <Value key="Services_HungerWeight">1</Value>
    <Value key="Services_ComfortWeight">0.5</Value>
    <Value key="Services_HygieneWeight">0.5</Value>
    <Value key="Services_BladderWeight">1</Value>
    <Value key="Services_EnergyWeight">2</Value>
    <Value key="Services_FunWeight">0.5</Value>
    <Value key="Services_SocialWeight">2</Value>
    <!-- Shopping: average -->
    <Value key="Shopping_HungerWeight">1</Value>
    <Value key="Shopping_ComfortWeight">0.5</Value>
    <Value key="Shopping_HygieneWeight">0.5</Value>
    <Value key="Shopping_BladderWeight">1</Value>
    <Value key="Shopping_EnergyWeight">2</Value>
    <Value key="Shopping_FunWeight">0.5</Value>
    <Value key="Shopping_SocialWeight">2</Value>
    <!-- Skills: hard -->
    <Value key="Skills_HungerWeight">1.25</Value>
    <Value key="Skills_ComfortWeight">0.625</Value>
    <Value key="Skills_HygieneWeight">0.625</Value>
    <Value key="Skills_BladderWeight">1.25</Value>
    <Value key="Skills_EnergyWeight">2.5</Value>
    <Value key="Skills_FunWeight">0.625</Value>
    <Value key="Skills_SocialWeight">2.5</Value>
    <!-- Welcome: easy -->
    <Value key="Welcome_HungerWeight">0.8</Value>
    <Value key="Welcome_ComfortWeight">0.4</Value>
    <Value key="Welcome_HygieneWeight">0.4</Value>
    <Value key="Welcome_BladderWeight">0.8</Value>
    <Value key="Welcome_EnergyWeight">1.6</Value>
    <Value key="Welcome_FunWeight">0.4</Value>
    <Value key="Welcome_SocialWeight">1.6</Value>
    <!-- Games: easy -->
    <Value key="Games_HungerWeight">0.8</Value>
    <Value key="Games_ComfortWeight">0.4</Value>
    <Value key="Games_HygieneWeight">0.4</Value>
    <Value key="Games_BladderWeight">0.8</Value>
    <Value key="Games_EnergyWeight">1.6</Value>
    <Value key="Games_FunWeight">0.4</Value>
    <Value key="Games_SocialWeight">1.6</Value>
    <!-- Entertain: easy -->
    <Value key="Entertain_HungerWeight">0.8</Value>
    <Value key="Entertain_ComfortWeight">0.4</Value>
    <Value key="Entertain_HygieneWeight">0.4</Value>
    <Value key="Entertain_BladderWeight">0.8</Value>
    <Value key="Entertain_EnergyWeight">1.6</Value>
    <Value key="Entertain_FunWeight">0.4</Value>
    <Value key="Entertain_SocialWeight">1.6</Value>
    <!-- Residence: average -->
    <Value key="Residence_HungerWeight">1</Value>
    <Value key="Residence_ComfortWeight">0.5</Value>
    <Value key="Residence_HygieneWeight">0.5</Value>
    <Value key="Residence_BladderWeight">1</Value>
    <Value key="Residence_EnergyWeight">2</Value>
    <Value key="Residence_FunWeight">0.5</Value>
    <Value key="Residence_SocialWeight">2</Value>
  </Entry>
</Tuning>
"""#
}
