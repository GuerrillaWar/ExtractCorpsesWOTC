// This is an Unreal Script
//-----------------------------------------------------------
// Used by the visualizer system to control a Visualization Actor.
//-----------------------------------------------------------
class ExtractCorpses_Action_FultonExtraction extends X2Action;

var private vector Force;
var private int Ticks;



function Init()
{
	super.Init();
}


function CompleteAction()
{
	super.CompleteAction();
}

//------------------------------------------------------------------------------------------------
simulated state Executing
{
	simulated event EndState( name nmNext )
	{
		if (IsTimedOut()) // just in case something went wrong, get the pawn into the proper state
		{
			UnitPawn.EndRagDoll( );
		}
	}

Begin:
  UnitPawn.EnableRMA(true, true);
	UnitPawn.EnableRMAInteractPhysics(true);
	UnitPawn.bRunPhysicsWithNoController = true;

	UnitPawn.EndRagDoll();
	UnitPawn.StartRagDoll(false, vect(0,0,0), vect(0,0,0), false);
	Sleep(0.3f);
	UnitPawn.Mesh.AddForce(vect(0,0,1000), vect(0,0,0));
	Sleep(0.2f);

	Force.Z = 100;

	Ticks = 0;

	while (Ticks < 30)
	{
		UnitPawn.Mesh.AddForce(Force, vect(0,0,0));
		Force.Z = Force.Z * 1.3;
		Ticks++;
		Sleep(0.1f); // let them ragdoll for a bit, for effect.
	}
	Ticks = 0;
	CompleteAction();
}


defaultproperties
{
	TimeoutSeconds = 10.0f
}
