/* ===================================================================
 *                        Script Information:
 *
 * Name: Base Roleplay Script v1.0
 * Created by: Lukman
 * Github link: https://github.com/Lukman350/BaseRP-Script
 *
 * Thanks to:
 * SAMP Team
 * pBlueG for mysql
 * samp-incognito for streamer
 * Y_Less for YSI
 * SouthClaws for chrono
 * Zeek for crashdetect
 * ===================================================================
**/

#pragma compat 1
#pragma compress 0
#pragma dynamic 500000

#include <a_samp>
#include <a_mysql>
#include <streamer>
#include <sscanf2>
#include <chrono>
#include <crashdetect>
#include <YSI\y_timers>
#include <YSI\y_colours>

// Predefinitions
#define MYSQL_HOST "localhost"
#define MYSQL_USER "root"
#define MYSQL_PASS ""
#define MYSQL_DB   "baserp"

#define Func:%0(%1) forward %0(%1); public %0(%1)
#define SERVER_SHORTNAME "Base:RP"
#define SERVER_VERSION   "1.0.0"
#define SERVER_WEBURL    "https://github.com/Lukman350/BaseRP-Script"
#define MAX_CHARACTERS   (3)

#define SendErrorMessage(%0,%1) SendClientMessageEx(%0,X11_GREY_80,"ERROR: "%1)
#define SendSyntaxMessage(%0,%1) SendClientMessageEx(%0,X11_GREY_80,"USAGE: "%1)

#undef MAX_PLAYERS
#define MAX_PLAYERS 50


// ALL VARIABLE
new MySQL:g_DB;

// ALL ENUMS
enum ucpData {
  uID,
  uUsername[64],
  uEmail[64],
  uPassword[128],
  uSalt[128],
  uAdmin,
  uIP[24],
  uLogged,
  uLoginAttempts,
};
new UcpData[MAX_PLAYERS][ucpData];

enum charData {
  pID,
  pCreated,
  pGender,
  pOrigin[32],
  pSkin,
  pWorld,
  pInt,
  pMoney,
  pBankMoney,
  Float:pPos[4],
  Float:pHealth,
  Float:pArmor,
  pLoginDate,
  pLogged,
  pKicked,
  pHours,
  pMinutes,
  pSeconds,
  pLevel,
  pCharacter,
  pUsername[64]
};
new CharData[MAX_PLAYERS][charData];

new CharacterList[MAX_PLAYERS][MAX_CHARACTERS][MAX_PLAYER_NAME + 1];
new g_MysqlRaceCheck[MAX_PLAYERS];

main()
{
	print("\n----------------------------------");
	print(" Base Roleplay Script by Lukman");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
  print("Initialising gamemode...");

  Gamemode_Setup();

	#if defined main_OnGameModeInit
    return main_OnGameModeInit();
  #else
    return 1;
  #endif
}
#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit main_OnGameModeInit
#if defined main_OnGameModeInit
    forward main_OnGameModeInit();
#endif

// All Function
Gamemode_Setup() {
  mysql_connection();
  ManualVehicleEngineAndLights();
  Streamer_ToggleErrorCallback(1);
  SetGameModeText(SERVER_SHORTNAME" v"SERVER_VERSION);
  SendRconCommand(sprintf("weburl %s", SERVER_WEBURL));
  return 1;
}


mysql_connection() {
  g_DB = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DB);
  if (mysql_errno(g_DB) != 0) {
    printf("[Database] MySQL connection to database %s failed!", MYSQL_DB);
  } else {
    printf("[Database] MySQL connection to database %s success!", MYSQL_DB);
  }
  return 1;
}

mysql_closeconnection() {
  mysql_close(g_DB);
  return 1;
}

SavePlayer(playerid) {
  Save_UCP(playerid);
  Save_Char(playerid);
  return 1;
}

Save_UCP(playerid) {
  if (!UcpData[playerid][uLogged])
    return 0;

  new query[1024];
  format(query,sizeof(query),"UPDATE `ucp` SET `username` = '%s', `email` = '%s', `admin` = '%d', `ip` = '%s' WHERE `id` = '%d'",
    UcpData[playerid][uUsername],
    UcpData[playerid][uEmail],
    UcpData[playerid][uAdmin],
    UcpData[playerid][uIP],
    UcpData[playerid][uID]
  );
  return mysql_tquery(g_DB, query);
}

Save_Char(playerid) {
  if (!CharData[playerid][pLogged])
    return 0;

  CharData[playerid][pWorld] = GetPlayerVirtualWorld(playerid);
  CharData[playerid][pInt] = GetPlayerInterior(playerid);
  GetPlayerPos(playerid, CharData[playerid][pPos][0], CharData[playerid][pPos][1], CharData[playerid][pPos][2]);
  GetPlayerFacingAngle(playerid, CharData[playerid][pPos][3]);
  GetPlayerHealth(playerid, CharData[playerid][pHealth]);
  GetPlayerArmor(playerid, CharData[playerid][pArmor]);

  new query[1024];
  format(query,sizeof(query),"UPDATE `chars` SET `created` = '%d', `gender` = '%d', `origin` = '%s', `skin` = '%d', `world` = '%d', `interior` = '%d', `money` = '%d', `bankmoney` = '%d', `posx` = '%f', `posy` = '%f', `posz` = '%f', `posa` = '%f', `health` = '%.2f', `armor` = '%.2f', `logindate` = '%d' WHERE `id` = '%d'",
    CharData[playerid][pCreated],
    CharData[playerid][pGender],
    CharData[playerid][pOrigin],
    CharData[playerid][pSkin],
    CharData[playerid][pWorld],
    CharData[playerid][pInt],
    CharData[playerid][pMoney],
    CharData[playerid][pBankMoney],
    CharData[playerid][pPos][0],
    CharData[playerid][pPos][1],
    CharData[playerid][pPos][2],
    CharData[playerid][pPos][3],
    CharData[playerid][pHealth],
    CharData[playerid][pArmor],
    CharData[playerid][pLoginDate],
    CharData[playerid][pID]
  );
  mysql_tquery(g_DB, query);

  format(query,sizeof(query),"UPDATE `chars` SET `hours` = '%d', `minutes` = '%d', `seconds` = '%d', `level` = '%d' WHERE `id` = '%d'",
    CharData[playerid][pHours],
    CharData[playerid][pMinutes],
    CharData[playerid][pSeconds],
    CharData[playerid][pLevel],
    CharData[playerid][pID]
  );
  mysql_tquery(g_DB, query);
  return 1;
}

IsValidRoleplayName(const name[]) {
    if(!name[0] || strfind(name, "_") == -1)
        return 0;

    else for (new i = 0, len = strlen(name); i != len; i ++) {
    if((i == 0) && (name[i] < 'A' || name[i] > 'Z'))
            return 0;

        else if((i != 0 && i < len  && name[i] == '_') && (name[i + 1] < 'A' || name[i + 1] > 'Z'))
            return 0;

        else if((name[i] < 'A' || name[i] > 'Z') && (name[i] < 'a' || name[i] > 'z') && name[i] != '_' && name[i] != '.')
            return 0;
    }
    return 1;
}

GetName(playerid, underscore=1)
{
    new
        name[MAX_PLAYER_NAME + 1];

    GetPlayerName(playerid, name, sizeof(name));

    if(!underscore) {
        for (new i = 0, len = strlen(name); i < len; i ++) {
                if(name[i] == '_') name[i] = ' ';
        }
    }
    return name;
}

IsCharLogged(playerid) {
  return (IsPlayerConnected(playerid) && CharData[playerid][pLogged]);
}

KickEx(playerid, time = 200) {
  if(PlayerData[playerid][pKicked])
    return 0;

  if(IsCharLogged(playerid)) {
    Save_UCP(playerid);
  }

  CharData[playerid][pKicked] = 1;
  SetTimerEx("KickTimer", time, false, "d", playerid);
  return 1;
}

Func:KickTimer(playerid) {
  Kick(playerid);
  return 1;
}

CheckAccount(playerid) {
  new query[256];
  format(query, sizeof(query), "SELECT * FROM `ucp` WHERE `username` = '%s' LIMIT 1;", GetName(playerid));
  mysql_tquery(g_DB, query, "OnUCPLoaded", "dd", playerid, g_MysqlRaceCheck[playerid]);

  return 1;
}

ShowCharacterMenu(playerid) {
  new name[MAX_CHARACTERS * 25], count;

  for (new i; i < MAX_CHARACTERS; i ++) if(CharacterList[playerid][i][0] != EOS) {
    strcat(name, sprintf("%s\n", CharacterList[playerid][i]));
    count++;
  }

  if(count < MAX_CHARACTERS)
    strcat(name, "<New Character>");

  Dialog_Show(playerid, DIALOG_SELECTCHAR, DIALOG_STYLE_LIST, "Character List", name, "Select", "Quit");
  return 1;
}

// ALL Callback

Func:OnUCPLoaded(playerid, race_check) {
  if (race_check != g_MysqlRaceCheck[playerid]) 
    return KickEx(playerid);

  new rows = cache_num_rows();
  if (rows) {
    cache_get_value_name_int(0, "id", UcpData[playerid][uID]);
    cache_get_value_name_int(0, "admin", UcpData[playerid][uAdmin]);
    cache_get_value_name(0, "email", UcpData[playerid][uEmail], 64);
    cache_get_value_name(0, "username", UcpData[playerid][uUsername], 64);
    cache_get_value_name(0, "password", UcpData[playerid][uPassword], 128);
    cache_get_value_name(0, "salt", UcpData[playerid][uSalt], 128);
    cache_get_value_name(0, "ip", UcpData[playerid][uIP], 24);

    Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "LOGIN", WHITE"Selamat datang kembali "YELLOW"%s"WHITE", silahkan masukkan password Anda dibawah:", "Login", "Cancel", GetName(playerid, 0));
  } else {
    UcpData[playerid][uPassword] = UcpData[playerid][uSalt] = EOS;
    Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "REGISTER", WHITE"Akun dengan nama "YELLOW"%s "WHITE"tidak terdaftar. Silahkan masukkan password dibawah untuk mendaftar:", "Register", "Close", GetName(playerid, 0));
  }
  return 1;
}

Func:OnCharacterLoaded(playerid) {
  for (new i = 0; i < MAX_CHARACTERS; i ++) {
    CharacterList[playerid][i][0] = EOS;
  }

  for (new i = 0; i < cache_num_rows(); i ++) {
    cache_get_value_name(i, "name", CharacterList[playerid][i], 128);
  }

  ShowCharacterMenu(playerid);
  return 1;
}

Func:OnPlayerLoaded(playerid) {
  new rows = cache_num_rows();

  if (rows) {
    cache_get_value_name_int(0, "id", CharData[playerid][pID]);
    cache_get_value_name_int(0, "gender", CharData[playerid][pGender]);
    cache_get_value_name_int(0, "created", CharData[playerid][pCreated]);
    cache_get_value_name_int(0, "skin", CharData[playerid][pSkin]);
    cache_get_value_name_int(0, "world", CharData[playerid][pWorld]);
    cache_get_value_name_int(0, "interior", CharData[playerid][pInt]);
    cache_get_value_name_int(0, "money", CharData[playerid][pMoney]);
    cache_get_value_name_int(0, "bankmoney", CharData[playerid][pBankMoney]);
    cache_get_value_name_int(0, "logindate", CharData[playerid][pLoginDate]);
    cache_get_value_name_int(0, "hours", CharData[playerid][pHours]);
    cache_get_value_name_int(0, "minutes", CharData[playerid][pMinutes]);
    cache_get_value_name_int(0, "seconds", CharData[playerid][pSeconds]);
    cache_get_value_name_int(0, "level", CharData[playerid][pLevel]);
    cache_get_value_name_float(0, "posx", CharData[playerid][pPos][0]);
    cache_get_value_name_float(0, "posy", CharData[playerid][pPos][1]);
    cache_get_value_name_float(0, "posz", CharData[playerid][pPos][2]);
    cache_get_value_name_float(0, "posa", CharData[playerid][pPos][3]);
    cache_get_value_name_float(0, "health", CharData[playerid][pHealth]);
    cache_get_value_name_float(0, "armor", CharData[playerid][pArmor]);
    cache_get_value_name(0, "username", CharData[playerid][pUsername], 64);
    cache_get_value_name(0, "origin", CharData[playerid][pOrigin], 64);
    CharData[playerid][pLogged] = 1;
    if (!CharData[playerid][pCreated]) {
      SetPVarInt(playerid, "Created",1);

      SetSpawnInfo(playerid, NO_TEAM, 98, 258.0770, -42.3550, 1002.0234, 0.0, 0, 0, 0, 0, 0, 0);
      TogglePlayerSpectating(playerid, 0);
      TogglePlayerControllable(playerid, 0);
    } else {
      SetSpawnInfo(playerid, NO_TEAM, CharData[playerid][pSkin], CharData[playerid][pPos][0], CharData[playerid][pPos][1], CharData[playerid][pPos][2], CharData[playerid][pPos][3], 0, 0, 0, 0, 0, 0);

      TogglePlayerSpectating(playerid, 0);
      TogglePlayerControllable(playerid, 0);

      CancelSelectTextDraw(playerid);
      SetTimerEx("SpawnTimer", 1000, false, "d", playerid);
    }
  }
  return 1;
}

public OnGameModeExit()
{
  foreach (new i : Player) {
    SavePlayer(i);
  }

  mysql_closeconnection();
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	if (IsValidRoleplayName(GetName(playerid))) {
    SendErrorMessage(playerid, "Format Nama tidak sesuai.");
    SendErrorMessage(playerid, "Gunakan nama dengan format nama biasa.");
    SendErrorMessage(playerid, "Contoh: lukman, java, javascript, pawn");
    KickEx(playerid);
  }

  if (!CharData[playerid][pKicked]) {
    CheckAccount(playerid);
    SetPlayerColor(playerid, 0xFFFFFFFF);
  }
	return 1;
}

public OnPlayerConnect(playerid)
{
  g_MysqlRaceCheck[playerid]++;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
  g_MysqlRaceCheck[playerid]++;
	return 1;
}

public OnPlayerSpawn(playerid)
{
  SetPlayerScore(playerid, CharData[playerid][pLevel]);
  SetPlayerSkin(playerid, CharData[playerid][pSkin]);
  if (!CharData[playerid][pCreated]) {
    if(GetPVarInt(playerid, "Created")) {
    }
  }
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

// All Dialogs
Dialog:DIALOG_LOGIN(playerid, response, listitem, inputtext[]) {
  if (!response)
    return KickEx(playerid);

  if (isnull(inputtext))
    return Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "LOGIN", WHITE"Selamat datang kembali "YELLOW"%s"WHITE", silahkan masukkan password Anda dibawah:", "Login", "Cancel", GetName(playerid, 0));

  new hash[65];
  SHA256_PassHash(inputtext, UcpData[playerid][uSalt], hash, sizeof(hash));

  if(strcmp(hash, UcpData[playerid][pPassword])) {
    if (++UcpData[playerid][uLoginAttempts] >= 3) {
      UcpData[playerid][uLoginAttempts] = 0;
      SendErrorMessage(playerid, "Anda telah memasukkan password yang salah sebanyak 3 kali.");
      SendErrorMessage(playerid, "Anda akan dikick.");
      KickEx(playerid);
    } else {
      Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "LOGIN", WHITE"Selamat datang kembali "YELLOW"%s"WHITE", silahkan masukkan password Anda dibawah:\n"RED"Password salah! Sisa kesempatan: %d / 3", "Login", "Cancel", GetName(playerid, 0), UcpData[playerid][uLoginAttempts]);
    }
    return 1;
  }

  if (!strcmp(UcpData[playerid][pMail], ""))
    return Dialog_Show(playerid, DIALOG_EMAIL, DIALOG_STYLE_INPUT, "Email", WHITE"Tolong masukkan email dibawah ini:", "Enter", "Quit");

  UcpData[playerid][uLogged] = 1;
  new query[256];
  format(query, sizeof(query), "SELECT `name` FROM `chars` WHERE `username` = '%s' LIMIT %d;", UcpData[playerid][uUsername], MAX_CHARACTERS);
  mysql_tquery(g_DB, query, "OnCharacterLoaded", "d", playerid);
  return 1;
}

Dialog:DIALOG_SELECTCHAR(playerid, response, listitem, inputtext[]) {
  if (!response)
    return KickEx(playerid);

  for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++) if(UcpData[i][uUsername][0] != EOS)
  {
    if(!strcmp(UcpData[i][uUsername], GetName(playerid)) && i != playerid)
    {
      SendErrorMessage(playerid, "Seseorang sedang login menggunakan UCP yang sama.");
      KickEx(playerid);
      return 1;
    }
  }

  if (CharacterList[playerid][listitem][0] == EOS)
    return Dialog_Show(playerid, DIALOG_CREATECHAR, DIALOG_STYLE_INPUT, "Create Character", WHITE"Masukkan nama karakter, maksimal 24 karakter\n\nContoh: "YELLOW"Sean_Rutledge, Eddison_Murphy dan lainnya.", "Create", "Back");

  CharData[playerid][pCharacter] = listitem;
  SetPlayerName(playerid, CharacterList[playerid][listitem]);

  mysql_tquery(g_DB, sprintf("SELECT * FROM `chars` WHERE `name` = '%s' ORDER BY `id` ASC LIMIT 1;", CharacterList[playerid][CharData[playerid][pCharacter]]), "OnPlayerLoaded", "d", playerid);
  return 1;
}