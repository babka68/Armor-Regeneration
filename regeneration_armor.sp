#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Armor Regeneration", 
	author = "babka68", 
	description = "Данный плагин восстанавливает броню игрокам и может выдавать шлем.", 
	version = "1.0", 
	url = "https://vk.com/zakazserver68"
};

Handle g_hRegenTimer[MAXPLAYERS + 1];
int g_MaxArmor, g_Count;
float g_Interval;
bool b_Enable_HasHelmet;

public void OnPluginStart()
{
	ConVar cvar;
	cvar = CreateConVar("sm_armor_regen_interval", "1.0", "Интервал в секундах между восстановлением брони Armor (по умолчанию 1.0)", _, true, 0.0, true, 10.0);
	cvar.AddChangeHook(CVarChanged_Interval);
	g_Interval = cvar.FloatValue;
	
	cvar = CreateConVar("sm_armor_regen_count", "1", "Сколько будет восстановлено брони Armor за интервал (по умолчанию 1)", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_Count);
	g_Count = cvar.IntValue;
	
	cvar = CreateConVar("sm_armor_regen_max", "100", "Максимальное количество Armor до которых нужно восстанавливать броню(по умолчанию 100)", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_Max_Armor);
	g_MaxArmor = cvar.IntValue;
	
	cvar = CreateConVar("sm_helmet", "0", "Давать ли шлем после повреждения?", _, true, 0.0, true, 1.0);
	cvar.AddChangeHook(CVarChanged_Enable_HasHelmet);
	b_Enable_HasHelmet = cvar.BoolValue;
	
	HookEvent("player_hurt", HookPlayerHurt);
	AutoExecConfig(true, "sm_regeneration_armor");
}

public void CVarChanged_Interval(ConVar CVar, const char[] oldValue, const char[] newValue)
{
	g_Interval = CVar.FloatValue;
}

public void CVarChanged_Max_Armor(ConVar CVar, const char[] oldValue, const char[] newValue)
{
	g_MaxArmor = CVar.IntValue;
}

public void CVarChanged_Count(ConVar CVar, const char[] oldValue, const char[] newValue)
{
	g_Count = CVar.IntValue;
}

public void CVarChanged_Enable_HasHelmet(ConVar CVar, const char[] oldValue, const char[] newValue)
{
	b_Enable_HasHelmet = CVar.BoolValue;
}

public void HookPlayerHurt(Handle event, const char[] name, bool dontBroadcast)
{
	int iUserId = GetEventInt(event, "userid");
	int client = GetClientOfUserId(iUserId);
	
	if (g_hRegenTimer[client] == null)
	{
		g_hRegenTimer[client] = CreateTimer(g_Interval, Regenerate, client, TIMER_REPEAT);
	}
}

public Action Regenerate(Handle timer, any client)
{
	int ClientArmor = GetClientArmor(client);
	
	if (ClientArmor < g_MaxArmor)
	{
		SetClientArmor(client, ClientArmor + g_Count);
	}
	else
	{
		SetClientArmor(client, g_MaxArmor);
		g_hRegenTimer[client] = null;
		KillTimer(timer);
	}
}

void SetClientArmor(int client, int amount)
{
	if (IsClientInGame(client) && !IsFakeClient(client) && b_Enable_HasHelmet)
	{
		SetEntProp(client, Prop_Send, "m_bHasHelmet", true); // Шлем
	}
	SetEntProp(client, Prop_Data, "m_ArmorValue", amount, 1);
} 
