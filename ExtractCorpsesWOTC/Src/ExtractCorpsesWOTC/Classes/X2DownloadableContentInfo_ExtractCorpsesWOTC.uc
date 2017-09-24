class X2DownloadableContentInfo_ExtractCorpsesWOTC extends X2DownloadableContentInfo Config(Game);

static event OnPostTemplatesCreated()
{
	`log("ExtractCorpses :: Present And Correct");
  class'ExtractCorpses_EnableCarrying'.static.UpdateCharacterTemplates();
}

static function UpdateAnimations(out array<AnimSet> CustomAnimSets, XComGameState_Unit UnitState, XComUnitPawn Pawn)
{
  local X2CharacterTemplate CharTemplate;
  CharTemplate = UnitState.GetMyTemplate();

  if (class'ExtractCorpses_EnableCarrying'.static.CanBeCarried(CharTemplate))
  {

    if (Pawn.CarryingUnitAnimSets.Find(AnimSet'Soldier_ANIM.Anims.AS_Carry') == INDEX_NONE)
    {
      Pawn.CarryingUnitAnimSets.AddItem(AnimSet'Soldier_ANIM.Anims.AS_Carry');
    }

    if (Pawn.BeingCarriedAnimSets.Find(AnimSet'Soldier_ANIM.Anims.AS_Body') == INDEX_NONE)
    {
      Pawn.BeingCarriedAnimSets.AddItem(AnimSet'Soldier_ANIM.Anims.AS_Body');
    }
  }
}
