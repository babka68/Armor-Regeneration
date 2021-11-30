#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =  {
	name = "Armor Regeneration", 
	author = "babka68", 
	description = "Данный плагин восстанавливает броню игрокам и может выдавать шлем.", 
	version = "1.0", 
	url = "https://vk.com/zakazserver68"
};

Handle g_hregenTimer[MAXPLAYERS + 1];
int g_imaxArmor, g_icount;
float g_finterval;
bool g_benable_HasHelmet;

public void OnPluginStart() {
	ConVar cvar;
	cvar = CreateConVar("sm_armor_regen_interval", "1.0", "Интервал в секундах между восстановлением брони (по умолчанию 1.0)", _, true, 0.0, true, 10.0);
	cvar.AddChangeHook(CVarChanged_Interval);
	g_finterval = cvar.FloatValue;
	
	cvar = CreateConVar("sm_armor_regen_count", "1", "Сколько будет восстановлено брони за интервал (по умолчанию 1)", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_Count);
	g_icount = cvar.IntValue;
	
	cvar = CreateConVar("sm_armor_regen_max", "127", "Максимальное количество до которых нужно восстанавливать броню(по умолчанию 127)", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_Max_Armor);
	g_imaxArmor = cvar.IntValue;
	
	cvar = CreateConVar("sm_helmet", "0", "Давать ли шлем после повреждения?", _, true, 0.0, true, 1.0);
	cvar.AddChangeHook(CVarChanged_Enable_HasHelmet);
	g_benable_HasHelmet = cvar.BoolValue;
	
	HookEvent("player_hurt", HookPlayerHurt);
	AutoExecConfig(true, "sm_regeneration_armor");
}

public void CVarChanged_Interval(ConVar CVar, const char[] oldValue, const char[] newValue) {
	g_finterval = CVar.FloatValue;
}

public void CVarChanged_Max_Armor(ConVar CVar, const char[] oldValue, const char[] newValue) {
	g_imaxArmor = CVar.IntValue;
}

public void CVarChanged_Count(ConVar CVar, const char[] oldValue, const char[] newValue) {
	g_icount = CVar.IntValue;
}

public void CVarChanged_Enable_HasHelmet(ConVar CVar, const char[] oldValue, const char[] newValue) {
	g_benable_HasHelmet = CVar.BoolValue;
}

public void HookPlayerHurt(Event event, const char[] name, bool dontBroadcast) {
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	
	if (g_hregenTimer[client] == null) {
		g_hregenTimer[client] = CreateTimer(g_finterval, Regenerate, client, TIMER_REPEAT);
	}
}

public Action Regenerate(Handle timer, any client) {
	int clientarmor = GetClientArmor(client);
	
	if (clientarmor < g_imaxArmor) {
		SetClientArmor(client, clientarmor + g_icount);
	}
	else {
		SetClientArmor(client, g_imaxArmor);
		g_hregenTimer[client] = null;
		KillTimer(timer);
	}
}

void SetClientArmor(int client, int amount) {
	if (IsClientInGame(client) && !IsFakeClient(client) && g_benable_HasHelmet) {
		SetEntProp(client, Prop_Send, "m_bHasHelmet", true); // Шлем
	}
	SetEntProp(client, Prop_Data, "m_ArmorValue", amount, 1);
} 
