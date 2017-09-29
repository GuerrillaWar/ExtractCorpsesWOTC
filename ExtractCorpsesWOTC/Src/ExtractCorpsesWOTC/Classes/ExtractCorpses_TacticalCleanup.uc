// This is an Unreal Script
class ExtractCorpses_TacticalCleanup extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
  local array<X2DataTemplate> Templates;

  `log("ExtractCorpses :: Registering Tactical Event Listeners");

  Templates.AddItem(AddTacticalCleanupEvent());

  return Templates;
}


static function X2EventListenerTemplate AddTacticalCleanupEvent()
{
  local X2EventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EventListenerTemplate', Template, 'ExtractCorpses_TacticalCleanup');

	Template.RegisterInTactical = true;
	Template.AddEvent('TacticalGameEnd', CleanupTacticalGame);

	return Template;
}


static protected function EventListenerReturn CleanupTacticalGame(Object EventData, Object EventSource, XComGameState GivenGameState, name EventID, Object CallbackData)
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_BattleData BattleData;
	local XComGameState_HeadquartersXCom XComHQ;
	local int LootIndex;
	local X2ItemTemplateManager ItemTemplateManager;
	local XComGameState_Item ItemState;
	local X2ItemTemplate ItemTemplate;
	local XComGameState_Unit UnitState;
	local LootResults PendingAutoLoot;
	local XComLWTuple Tuple;
	local Name LootTemplateName;
	local bool bDoAwardCorpseLoot;
	local array<Name> RolledLoot;

	History = `XCOMHISTORY;
	`log("ExtractCorpses :: Recovering Evacced Enemy Corpses");

	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	// always process so other mods can tap into event to change behaviour
	foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		Tuple = new class'XComLWTuple';
		Tuple.Id = 'ExtractCorpses_AwardLoot';
		Tuple.Data.Add(1);

		Tuple.Data[0].kind = XComLWTVBool;
		Tuple.Data[0].b = (
			(UnitState.IsAdvent() || UnitState.IsAlien()) && // is an enemy
			!BattleData.AllTacticalObjectivesCompleted() && // is NOT a tactical victory
			UnitState.bBodyRecovered // body is recovered
		);

		`XEVENTMGR.TriggerEvent('ExtractCorpses_AwardLoot', Tuple, UnitState, none);

		bDoAwardCorpseLoot = Tuple.Data[0].b;

		if (bDoAwardCorpseLoot) {
			class'X2LootTableManager'.static.GetLootTableManager().RollForLootCarrier(UnitState.GetMyTemplate().Loot, PendingAutoLoot);
			if( PendingAutoLoot.LootToBeCreated.Length > 0 )
			{
				foreach PendingAutoLoot.LootToBeCreated(LootTemplateName)
				{
					ItemTemplate = ItemTemplateManager.FindItemTemplate(LootTemplateName);
					RolledLoot.AddItem(ItemTemplate.DataName);
				}

			}
			PendingAutoLoot.LootToBeCreated.Remove(0, PendingAutoLoot.LootToBeCreated.Length);
			PendingAutoLoot.AvailableLoot.Remove(0, PendingAutoLoot.AvailableLoot.Length);
		}
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Award ExtractCorpses Loot");
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	NewGameState.AddStateObject(XComHQ);

	for( LootIndex = 0; LootIndex < RolledLoot.Length; ++LootIndex )
	{
		`log(" - " @ String(RolledLoot[LootIndex]));
		// create the loot item
		ItemState = ItemTemplateManager.FindItemTemplate(
			RolledLoot[LootIndex]).CreateInstanceFromTemplate(NewGameState);
		NewGameState.AddStateObject(ItemState);

		// assign the XComHQ as the new owner of the item
		ItemState.OwnerStateObject = XComHQ.GetReference();

		// add the item to the HQ's inventory of loot items
		XComHQ.PutItemInInventory(NewGameState, ItemState, true);
	}

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	return ELR_NoInterrupt;
}
