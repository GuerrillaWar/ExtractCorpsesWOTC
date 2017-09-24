class ExtractCorpses_EnableCarrying extends Object
	dependson(XComContentManager, X2CharacterTemplateManager)
	config(ExtractCorpses);

var const config array<name> CarryableCharacterTemplates;
var const config array<name> CarryableCharacterGroups;

static function bool CanBeCarried(X2CharacterTemplate CharTemplate) 
{
  return (
    default.CarryableCharacterGroups.Find(CharTemplate.CharacterGroupName) != INDEX_NONE ||
    default.CarryableCharacterTemplates.Find(CharTemplate.DataName) != INDEX_NONE
  );
}

static function UpdateCharacterTemplates()
{
	local X2CharacterTemplateManager Manager;
	local name CharTemplateName;
	local X2DataTemplate IterTemplate;
	local X2CharacterTemplate CharTemplate;

	Manager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

	`log("ExtractCorpses :: Updating Character Templates for Carrying");
	foreach default.CarryableCharacterTemplates(CharTemplateName) {
		`log("  - " @ CharTemplateName);
		UpdateCharacterForCarrying(Manager.FindCharacterTemplate(CharTemplateName));
	}

	foreach Manager.IterateTemplates(IterTemplate, none)
	{
		CharTemplate = X2CharacterTemplate(IterTemplate);

		if (static.CanBeCarried(CharTemplate))
    {
			`log("  - " @ CharTemplate.DataName @ " from " @ CharTemplate.CharacterGroupName);
			UpdateCharacterForCarrying(CharTemplate);
		}
	}
}

static function UpdateCharacterForCarrying(X2CharacterTemplate Template)
{
	Template.bCanBeCarried = true;
}

