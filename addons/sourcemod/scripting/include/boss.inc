#pragma semicolon 1

#define DEBUG

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <global>

#if defined boss_included
	#endinput
#endif
#define boss_included

#define BOSS_MODULE_VERSION "0.1"

ArrayList bossess;
ArrayList bossName;
ArrayList bossBaseHealth;
ArrayList bossPerEnemyHealth;
ArrayList bossSpeed;
ArrayList bossGravity;
ArrayList bossDamage;
ArrayList bossDamageLM;
ArrayList bossModel;
ArrayList bossArmsModel;
ArrayList bossPrimaryWeapon;
ArrayList bossPrimaryWeaponVModel;
ArrayList bossPrimaryWeaponWModel;
ArrayList bossSecondaryWeapon;
ArrayList bossSecondaryWeaponVModel;
ArrayList bossSecondaryWeaponWModel;
ArrayList bossCanJump;
ArrayList bossTeam;

methodmap ZBoss{
	public ZBoss(int value){
		return view_as<ZBoss>(value);
	}
	property int id{
		public get(){
			return view_as<int>(this);
		}
	}
	property int baseHealth{
		public get(){
			return bossBaseHealth.Get(this.id);
		}
		public set(int value){
			bossBaseHealth.Set(this.id, value);
		}
	}
	property int perEnemyHealth{
		public get(){
			return bossPerEnemyHealth.Get(this.id);
		}
		public set(int value){
			bossPerEnemyHealth.Set(this.id, value);
		}
	}
	property float speed{
		public get(){
			return bossSpeed.Get(this.id);
		}
		public set(float value){
			bossSpeed.Set(this.id, value);
		}
	}
	property float gravity{
		public get(){
			return bossGravity.Get(this.id);
		}
		public set(float value){
			bossGravity.Set(this.id, value);
		}
	}
	property float damage{
		public get(){
			return bossDamage.Get(this.id);
		}
		public set(float value){
			bossDamage.Set(this.id, value);
		}
	}
	property float damageLM{
		public get(){
			return bossDamageLM.Get(this.id);
		}
		public set(float value){
			bossDamageLM.Set(this.id, value);
		}
	}
	property bool canJump{
		public get(){
			return bossCanJump.Get(this.id);
		}
		public set(int value){
			bossCanJump.Set(this.id, value);
		}
	}
	property int team{
		public get(){
			return bossTeam.Get(this.id);
		}
		public set(int value){
			bossTeam.Set(this.id, value);
		}
	}
}

void InitBoss(){
	bossName = CreateArray(ByteCountToCells(32));
	bossBaseHealth = CreateArray(1);
	bossPerEnemyHealth = CreateArray(1);
	bossSpeed = CreateArray(1);
	bossGravity = CreateArray(1);
	bossDamage = CreateArray(1);
	bossDamageLM = CreateArray(1);
	bossModel = CreateArray(ByteCountToCells(256));
	bossArmsModel = CreateArray(ByteCountToCells(256));
	bossPrimaryWeapon = CreateArray(1);
	bossPrimaryWeaponVModel = CreateArray(ByteCountToCells(256));
	bossPrimaryWeaponWModel = CreateArray(ByteCountToCells(256));
	bossSecondaryWeapon = CreateArray(1);
	bossSecondaryWeaponVModel = CreateArray(ByteCountToCells(256));
	bossSecondaryWeaponWModel = CreateArray(ByteCountToCells(256));
	bossCanJump = CreateArray(1);
}
void ClearBoss(){
	bossName.Clear();
	bossBaseHealth.Clear();
	bossPerEnemyHealth.Clear();
	bossSpee.Clear();
	bossGravity.Clear();
	bossDamage.Clear();
	bossDamageLM.Clear();
	bossModel.Clear();
	bossArmsModel.Clear();
	bossPrimaryWeapon.Clear();
	bossPrimaryWeaponVModel.Clear();
	bossPrimaryWeaponWModel.Clear();
	bossSecondaryWeapon.Clear();
	bossSecondaryWeaponVModel.Clear();
	bossSecondaryWeaponWModel.Clear();
	bossCanJump.Clear();
}
void CreateBoss(char[] name, int baseHp, int perEnemyHp, float speed, float, gravity, 
				float damage, float lmDamage, char[] model, char[] arms,char[] pWeap,
				char[] pWeapVModel, char[] pWeapWModel, char[] sWeap, char[] sWeapVModel,
				char[] sWeapWModel, bool canJump, int team){
	ZBoss boss = ZBoss(bossess.Length);
	bossName.PushString(name);
	boss.baseHealth = baseHp;
	boss.perEnemyHealth = perEnemyHp;
	boss.speed = speed;
	boss.gravity = gravity;
	boss.damage = damage;
	boss.damageLM = lmDamage;
	bossModel.PushString(model);
	bossArmsModel.PushString(arms);
	bossPrimaryWeapon.PushString(pWeap);
	bossPrimaryWeaponVModel.PushString(pWeapVModel);
	bossPrimaryWeaponWModel.PushString(pWeapWModel);
	bossSecondaryWeapon.PushString(sWeap);
	bossSecondaryWeaponVModel.PushString(sWeapVModel);
	bossSecondaryWeaponWModel.PushString(sWeapWModel);
	boss.canJump = canJump;
	boss.team = team;
}