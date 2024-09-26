//codename: wamer_days_mq_03_spirit_of_sorrow
//purpose: handles the first real main quest step ( players must follow schruder's light bulb )
//release: 2023 as part of tranzit 2.0 v2 update
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_hud_message;
#include maps\mp\ombies\_zm_stats;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\zm_transit_sq;
#include maps\mp\zm_transit_distance_tracking;
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zm_alcatraz_utility;
#include maps\mp\zombies\_zm_afterlife;
#include maps\mp\zm_prison;
#include maps\mp\zombies\_zm;
#include maps\mp\gametypes_zm\_spawning;
#include maps\mp\zombies\_load;
#include maps\mp\zombies\_zm_clone;
#include maps\mp\zombies\_zm_ai_basic;
#include maps\mp\animscripts\shared;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zm_alcatraz_travel;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_perk_electric_cherry;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\_visionset_mgr;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\gametypes_zm\_hud;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zm_transit;


main()
{
    //replacefunc( maps\mp\zombies\_zm_buildables::player_set_buildable_piece, ::c_player_set_buildable_piece );
}


init()
{
    //flag_wait( "initial_blackscreen_passed" );
    precacheshader( "menu_mp_party_ease_icon" );
    precacheshader( "menu_mp_killstreak_select" );
    precacheshader( "specialty_tombstone_zombies" );
    level thread for_players();
    level thread CustomRoundNumber();
    flag_wait( "start_zombie_round_logic" );
    //level thread waypoint_set_players(); //tested to work now fully, good for step 7 of main quwst to indicate farm safe location where need to getg
    level notify("end_round_think");
    wait 0.05;
    level thread round_think();
    //buildbuildable( "dinerhatch", true, false );
}
for_players()
{
    level endon( "end_game" );
    while( true )
    {
        level waittill( "connected", pl );
       // pl thread brute_hud_visibility_off(); //default lua hud stays on too long
        pl thread test_firing_increase();
        pl thread score_hud_all();
        pl thread score_hud_all_ammo();
        pl thread play_name_hud_all();
    }
}


test_firing_increase()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    self endon( "death" );
    self waittill( "spawned_player" );
    self.jetgun_ammo_hud = newClientHudElem( self );
    self.jetgun_name_hud = newClientHudElem( self );
    self.jetgun_name_hud.alpha = 0;
    self.jetgun_ammo_hud.alpha = 0;
    wait 3.5;
    self thread jetgun_value_hud();
    wait 2;
    self thread sort_all_elements_in_group();
    wait 3.5;
    //self SetClientUIVisibilityFlag( "hud_visible", false );
    while( true )
    {
        if( self isFiring() )
        {
            if( self if_player_has_jetgun() )
            {
                self.custom_heat++;
                self.jetgun_ammo_hud SetValue( self.custom_heat );
                if( level.dev_time ){ iprintlnbold( "CUSTOM HEAT INCREASE" + self.custom_heat ); }
                wait 0.1;
                self SetWeaponOverheating( 0, 0 );
                if( self.custom_heat > 99 )
                {
                    guuguu = self getWeaponsListPrimaries();
                    self switchToWeapon( guuguu[ 0 ] );
                    self.custom_heat = 100;
                }
            }
            
        }
        else if( !self isfiring() )
        {
            if( self.custom_heat > 0  )
            {
                self.custom_heat--;
                self thread blink_jetgun_hud_heat();
                self SetWeaponOverheating( 0, 0 );
                self.jetgun_ammo_hud SetValue( self.custom_heat );
                if( level.dev_time ){ iprintlnbold( "CUSTOM HEAT DECREASE" + self.custom_heat ); }
                wait 1;
            }
        }
        wait 0.05;
    }    
}

blink_jetgun_hud_heat()
{
    self endon( "disconnect" );
    
   
    self.jetgun_ammo_hud fadeOverTime( 0.25 );
    self.jetgun_ammo_hud.color = ( 0.2, 1, 0 );
    wait 0.3;
    self.jetgun_ammo_hud.color fadeovertime( 0.1 );
    self.jetgun_ammo_hud.color = ( 0.65, 0.65, 0.65 );
    
    
}
if_player_has_jetgun()
{
    if( self hasWeapon( "jetgun_zm" ) )
    {
        if( self getCurrentWeapon() == "jetgun_zm" )
        {
            return true;
        }
        if( self getcurrentweapon() != "jetgun_zm" )
        {
            return false;
        }
    }
    return false;
}

sort_all_elements_in_group()
{
    /*
    self.jetgun_ammo_hud.x = self.jetgun_ammo_hud.x;
    self.jetgun_ammo_hud.y = self.jetgun_ammo_hud.y;

    self.jetgun_name_hud.x = self.jetgun_name_hud.x;
    self.jetgun_name_hud.y = self.jetgun_name_hud.y;

    self.real_score_hud.x = self.real_score_hud.x;
    self.real_score_hud.y = self.real_score_hud.y;

    self.survivor_points.x = self.survivor_points.x;
    self.survivor_points.y = self.survivor_points.y;

    
    self.weapon_ammo.x = self.weapon_ammo.x;
    self.weapon_ammo.y = self.weapon_ammo.y;

    self.ammo_slash.alignX = self.ammo_slash.alignX;
    self.ammo_slash.aligny = self.ammo_slash.aligny;

    self.weapon_ammo_stock.x = self.weapon_ammo_stock.x;
    self.weapon_ammo_stock.y = self.weapon_ammo_stock.y;

    self.say_ammo.x = self.say_ammo.x;
    self.say_ammo.y = self.say_ammo.y;


    self.playname.x = self.playname.x;
    self.playname.y = self.playname.y;
    */

    move_all( self.jetgun_ammo_hud, self.jetgun_name_hud, self.real_score_hud,
             self.survivor_points, self.weapon_ammo, self.ammo_slash,
             self.weapon_ammo_stock, self.say_ammo, self.playname );


}

move_all( opt, opt2, opt3, opt4, opt5, opt6, opt7, opt8, opt9 )
{
    x_num = 360;
    y_num = 280;

    opt.x = opt.x + x_num;
    opt.y = opt.y + y_num;

    opt2.x = opt2.x + x_num;
    opt2.y = opt2.y + y_num;

    opt3.x = opt3.x + x_num;
    opt3.y = opt3.y + y_num;

    opt4.x = opt4.x + x_num;
    opt4.y = opt4.y + y_num;

    opt5.x = opt5.x + x_num;
    opt5.y = opt5.y + y_num;

    opt6.x = opt6.x + x_num;
    opt6.y = opt6.y + y_num;

    opt7.x = opt7.x + x_num;
    opt7.y = opt7.y + y_num;

    opt8.x = opt8.x + x_num;
    opt8.y = opt8.y + y_num;

    opt9.x = opt9.x + x_num;
    opt9.y = opt9.y + y_num;


}
jetgun_value_hud()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    self.custom_heat = 0;
    
    self.jetgun_ammo_hud.x = 30;
    self.jetgun_ammo_hud.y = -62;
    self.jetgun_ammo_hud.color = ( 0.65, 0.65, 0.65 );
    self.jetgun_ammo_hud SetValue( self.custom_heat );
    self.jetgun_ammo_hud.fontScale = 1.22;
    self.jetgun_ammo_hud.alignX = "center";
    self.jetgun_ammo_hud.alignY = "center";
    self.jetgun_ammo_hud.horzAlign = "user_center";
    self.jetgun_ammo_hud.vertAlign = "user_center";
    self.jetgun_ammo_hud.sort = 1;
    self.jetgun_ammo_hud.alpha = 0;
    self.jetgun_ammo_hud fadeovertime( 1 );
    self.jetgun_ammo_hud.alpha = 1;
    
    self.jetgun_name_hud.x = -2.5;
    self.jetgun_name_hud.y = -62;
    self.jetgun_name_hud SetText( "^9Heat value: ^7" );
    self.jetgun_name_hud.fontScale = 1.22;
    self.jetgun_name_hud.alignX = "center";
    self.jetgun_name_hud.alignY = "center";
    self.jetgun_name_hud.horzAlign = "user_center";
    self.jetgun_name_hud.vertAlign = "user_center";
    self.jetgun_name_hud.sort = 1;
    self.jetgun_name_hud.alpha = 0;
    self.jetgun_name_hud fadeovertime( 1 );
    self.jetgun_name_hud.alpha = 1;


}

score_hud_all()
{
    self waittill( "spawned_player" );
    self.survivor_points = newClientHudElem( self );
    self.real_score_hud = newClientHudElem( self );
    self.survivor_points.alpha = 0;
    self.real_score_hud.alpha = 0;
    
    wait 3.5;
    self thread scores_hud();
    wait 2;
    self thread update_score();
    wait 4.5;
    //self setclientuivisibilityflag( "hud_visible", 0 );
    
    //level.fogtime = 9999;
}

brute_hud_visibility_off()
{
    self endon( "disconnect " );
    level endon( "end_game" );
    i = 0;
    while( isdefined( self ) )
    {
        self SetClientUIVisibilityFlag( "hud_visible",  false );
        wait 0.07;
        i++;
        if( level.dev_time ){ iprintln( "CURRENT BRUTE ATTEMPT" + i ); }
        if( i > 150 )
        {
            break;
        }
        wait 0.05;
    }
}
scores_hud()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    
    self.real_score_hud.x = 0;
    self.real_score_hud.y = -90;
    self.real_score_hud SetValue( self.score );
    self.real_score_hud.fontScale = 1.12;
    self.real_score_hud.alignX = "center";
    self.real_score_hud.alignY = "center";
    self.real_score_hud.horzAlign = "user_center";
    self.real_score_hud.vertAlign = "user_center";
    self.real_score_hud.sort = 1;
    self.real_score_hud.alpha = 0;
    self.real_score_hud fadeovertime( 1.5 );
    self.real_score_hud.alpha = 1;
    self.real_score_hud.color = ( 1, 0.7, 0 );

    
    self.survivor_points.x = -22.5;
    self.survivor_points.y = -90;
    self.survivor_points SetText( "^9$ ^7" );
    self.survivor_points.fontScale = 1.22;
    self.survivor_points.alignX = "center";
    self.survivor_points.alignY = "center";
    self.survivor_points.horzAlign = "user_center";
    self.survivor_points.vertAlign = "user_center";
    self.survivor_points.sort = 1;
    self.survivor_points.alpha = 0;
    self.survivor_points fadeovertime( 1.5 );
    self.survivor_points.alpha = 1;


}

update_score()
{
    self endon( "disconnect" );
    level endon( "end_game" );
    prev_score = self.score;
    while( true )
    {
        wait 0.05;
        if( self.score == prev_score )
        {
            wait 0.05;
            continue;
        }
        if( self.score > prev_score )
        {
            self.real_score_hud setvalue( self.score );
            prev_score = self.score;
            //if( self.real_score_hud.color == ( 1, 0.7, 0 ) )
            //{
                self thread change_col_score_up();
            //}
            wait 0.05;
        }

        else if ( self.score < prev_score )
        {
            self.real_score_hud setvalue( self.score );
            prev_score = self.score;
            //if( self.real_score_hud.color == ( 1, 0.7, 0 ) )
            //{
                self thread change_col_score_down();
           // }
            wait 0.05;
        }
    }
}

change_col_score_up()
{
    self.real_score_hud.color = ( 1, 0.7, 0 );
    
    self.real_score_hud fadeOverTime( 0.25 );
    self.real_score_hud.color = ( 0.25, 1, 0 );
    wait 0.25;
    self.real_score_hud fadeovertime( 0.15 );
    wait 0.15;
    self.real_score_hud.color = ( 1, 0.7, 0 );
}

change_col_score_down()
{
    self.real_score_hud.color = ( 1, 0.7, 0 );
    
    self.real_score_hud fadeOverTime( 0.35 );
    self.real_score_hud.color = ( 1, 0.1, 0 );
    wait 0.35;
    self.real_score_hud fadeovertime( 0.25 );
    wait 0.25;
    self.real_score_hud.color = ( 1, 0.7, 0 );
}












//WEAPON HUD STUFF

score_hud_all_ammo()
{
    self waittill( "spawned_player" );
    self.weapon_ammo = newClientHudElem( self );
    self.ammo_slash = newClientHudElem( self );
    self.weapon_ammo_stock = newClientHudElem( self );
    self.say_ammo = newClientHudElem( self );
    self.weapon_ammo.alpha = 0;
    self.ammo_slash.alpha = 0;
    self.weapon_ammo_stock.alpha = 0;
    self.say_ammo.alpha = 0;

    wait 3.5;
    self thread scores_hud_ammo();
    wait 2;
    self thread update_ammo_hud();
}
scores_hud_ammo()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    
    self.weapon_ammo.x = 15;
    self.weapon_ammo.y = -76;
    self.weapon_ammo.color = ( 0.65, 0.65, 0.65 );
    self.weapon_ammo SetValue(  self getWeaponAmmoClip( self getCurrentWeapon() ) );
    self.weapon_ammo.fontScale = 1.12;
    self.weapon_ammo.alignX = "center";
    self.weapon_ammo.alignY = "center";
    self.weapon_ammo.horzAlign = "user_center";
    self.weapon_ammo.vertAlign = "user_center";
    self.weapon_ammo.sort = 1;
    self.weapon_ammo.alpha = 0;
    self.weapon_ammo fadeovertime( 1.5 );
    self.weapon_ammo.alpha = 1;


    
    self.ammo_slash.x = 25;
    self.ammo_slash.y = -76;
    self.ammo_slash SetText( " ^9/ " );
    self.ammo_slash.fontScale = 1.22;
    self.ammo_slash.alignX = "center";
    self.ammo_slash.alignY = "center";
    self.ammo_slash.horzAlign = "user_center";
    self.ammo_slash.vertAlign = "user_center";
    self.ammo_slash.sort = 1;
    self.ammo_slash.alpha = 0;
    self.ammo_slash fadeovertime( 1.5 );
    self.ammo_slash.alpha = 1;

    
    self.weapon_ammo_stock.x = 37.5;
    self.weapon_ammo_stock.y = -76;
    self.weapon_ammo_stock SetValue(  self getWeaponAmmoStock( self getCurrentWeapon() ) );
    self.weapon_ammo_stock.fontScale = 1.12;
    self.weapon_ammo_stock.alignX = "center";
    self.weapon_ammo_stock.alignY = "center";
    self.weapon_ammo_stock.horzAlign = "user_center";
    self.weapon_ammo_stock.vertAlign = "user_center";
    self.weapon_ammo_stock.sort = 1;
    self.weapon_ammo_stock.alpha = 0;
    self.weapon_ammo_stock fadeovertime( 1.5 );
    self.weapon_ammo_stock.alpha = 1;


   
    self.say_ammo.x = 2.5;
    self.say_ammo.y = -76;
    self.say_ammo SetText( "^9Ammo: " );
    self.say_ammo.fontScale = 1.22;
    self.say_ammo.alignX = "right";
    self.say_ammo.alignY = "center";
    self.say_ammo.horzAlign = "user_center";
    self.say_ammo.vertAlign = "user_center";
    self.say_ammo.sort = 1;
    self.say_ammo.alpha = 0;
    self.say_ammo fadeovertime( 1.5 );
    self.say_ammo.alpha = 1;



}

update_ammo_hud()
{
    self endon( "disconnect" );
    level endon( "end_game" );
    weapon = self getCurrentWeapon();
    ammo = self getWeaponAmmoClip( weapon );
    stock = self getWeaponAmmoStock( weapon );
    ammo_clip = self getWeaponAmmoClip( weapon );
    ammo_stock = self getWeaponAmmoStock( weapon );
    while( true )
    {
        wait 0.05;
        if( ammo_clip == ammo )
        {
            wait 0.05;
        }
        weapon = self getCurrentWeapon();
        //self waittill( "weapon_fired" );
        ammo_clip = self getWeaponAmmoClip( weapon );
        ammo_stock = self getWeaponAmmoStock( weapon );
        
        if(  ammo_clip < ammo && self getCurrentWeapon() == weapon )
        {
            self.weapon_ammo setvalue( ammo_clip  );
            self.weapon_ammo.color = ( 0.65, 0.1, 0 );
            self.weapon_ammo_stock setValue( ammo_stock );
            ammo = self getWeaponAmmoClip( weapon );
            wait 0.05;
            self.weapon_ammo.color = ( 0.65, 0.65, 0.65 );
        }
        else if( ammo_clip > ammo && self getCurrentWeapon() == weapon )
        {
            self.weapon_ammo setvalue( ammo_clip );
            self.weapon_ammo_stock setValue( ammo_stock );
            ammo = self getweaponammoclip( weapon ); 
            wait 0.05;
            self.weapon_ammo.color = ( 0.1, 0.65, 0 );
        }
    }
}

change_col_ammo_clip_plus()
{
    self.weapon_ammo fadeOverTime( 0.1 );
    //self.weapon_ammo_stock fadeOverTime( 0.15 );
    self.weapon_ammo.color = ( 0.6, 1, 0 );
    //self.weapon_ammo_stock.color = ( 1, 0.4, 0 );
    wait 0.1;
    self.weapon_ammo fadeovertime( 0.05 );
    //self.weapon_ammo_stock fadeOverTime( 0.15 );
    wait 0.05;
    self.weapon_ammo.color = ( 0.65, 0.65, 0.65 );
    //self.weapon_ammo_stock.color = ( 1, 1, 1 );
}

change_col_ammo_clip_minus()
{
    self.weapon_ammo.color = (0.65, 0.65, 0.65 );
    self.weapon_ammo fadeOverTime( 0.1 );
    //self.weapon_ammo fadeOverTime( 0.15 );
    self.weapon_ammo.color = ( 1, 0.4, 0 );
    //self.weapon_ammo_stock.color = ( 1, 0.4, 0 );
    wait 0.1;
    self.weapon_ammo fadeovertime( 0.15 );
    //self.weapon_ammo_stock fadeOverTime( 0.15 );
    wait 0.15;
    self.weapon_ammo.color = ( 0.65, 0.65, 0.65 );
}


play_name_hud_all()
{
    self waittill( "spawned_player" );
    self.playname = newClientHudElem( self );
    self.playname.alpha = 0;
    wait 3.5;
    self thread name_hud();
    
    //level.fogtime = 9999;
}


name_hud()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    
    self.playname.x = 0;
    self.playname.y = -104;
    self.playname SetText(  self.name );
    self.playname.fontScale = 1.22;
    self.playname.alignX = "center";
    self.playname.alignY = "center";
    self.playname.horzAlign = "user_center";
    self.playname.vertAlign = "user_center";
    self.playname.sort = 1;
    self.playname.alpha = 0;
    //self.playname.color = ( 0.8, 0.4, 0 );
    self.playname.color = ( 0.65, 0.65, 0.65 );
    self.playname fadeovertime( 1.5 );
    self.playname.alpha = 1;
}




CustomRoundNumber() //original code by ZECxR3ap3r, modified it to my liking
{
	level.hud = create_simple_hud();
	level.hudtext = create_simple_hud();
    level.huddefcon = create_simple_hud();
    level.huddefconline = create_simple_hud();

    level.hud.x = 0;
    level.hud.y = -80;
    level.hudtext.x = 0;
    level.hudtext.y = -120;
	level.hud.alignx = "center";
	level.hud.aligny = "center"; //top
	level.hud.horzalign = "user_center";
	level.hud.vertalign = "user_center"; //top

	level.hudtext.alignx = "center";
	level.hudtext.aligny = "center"; //top
	level.hudtext.horzalign = "user_center";
	level.hudtext.vertalign = "user_center"; //top
    
    level.hud.fontscale = 3;
	level.hudtext.fontscale = 3;

	level.hud.color = ( 0.45, 0, 0 );
	//level.hudtext.color = ( 1, 1, 1 );

    level.hudtext settext("^9Loading Scenario: ");
	level.hud settext( level.round_number );
	level.huddefcon setText( "^9Scenario: " );
    level.huddefcon.fontscale = 1.25; 
	level.huddefcon.alpha = 0;
    
	level.huddefcon.alignx = "center"; 
	level.huddefcon.aligny = "center";
	level.huddefcon.horzalign = "user_center";
	level.huddefcon.vertalign = "user_center";
	level.huddefcon.x = 275;
	level.huddefcon.y = 215;

    level.huddefconline setShader( "white", 1, 50 );
    level.huddefconline.alignx = "center"; 
	level.huddefconline.aligny = "center";
	level.huddefconline.horzalign = "user_center";
	level.huddefconline.vertalign = "user_center";
	level.huddefconline.alpha = 0;
    
	level.huddefconline.x = 325;
	level.huddefconline.y = 180;

    level.huddefconline.color = ( 0.65, 0.5, 0 );
	level.hudtext.alpha = 0;
    level.hud.alpha = 0;
	flag_wait("initial_blackscreen_passed");
    wait 2.5;
    

	level.hud fadeovertime( 1.5 );
    level.hudtext fadeovertime( 1.5 );
    level.huddefcon fadeovertime( 1 );
    level.huddefconline fadeovertime( 1 );
    level.huddefconline.alpha = 1;
    level.huddefcon.alpha = 1;
	level.hud.alpha = 1;//0.8; //changed back for release
    level.hudtext.alpha = 1;//0.8; //changed back for release
	
	wait 4.5;

	level.hudtext fadeovertime( 1 );
    level.hud fadeovertime( 1 );
	level.hudtext.alpha = 0;
	level.hud moveovertime( 1 );
	level.hud.alignx = "center"; 
	level.hud.aligny = "center";
	level.hud.horzalign = "user_center";
	level.hud.vertalign = "user_center";
	level.hud.x = 307.5;
	level.hud.y = 200;

    
    wait 1.25;

    level.hud fadeOverTime( 0.5 );
    level.hud.alpha = 0;
    wait 1.5;
    level.hud.color = ( 0.65, 0.65, 0.65 );
    level.hud settext(  level.round_number );
    level.hud fadeovertime( 0.5 );
    
    level.hud.alpha = 1;
    wait 0.5;
}


round_think( restart ) //original code by ZECxR3ap3r, modified it to my liking
{
	if ( !isDefined( restart ) )
	{
		restart = 0;
	}
	for ( ;; )
	{
		maxreward = 50 * level.round_number;
		if ( maxreward > 500 )
		{
			maxreward = 500;
		}
		level.zombie_vars[ "rebuild_barrier_cap_per_round" ] = maxreward;
		level.pro_tips_start_time = getTime();
		level.zombie_last_run_time = getTime();
		level thread maps\mp\zombies\_zm_audio::change_zombie_music( "round_start" );
		maps\mp\zombies\_zm_powerups::powerup_round_start();
		players = get_players();
		array_thread( players, maps\mp\zombies\_zm_blockers::rebuild_barrier_reward_reset );
		if ( isDefined( level.headshots_only ) && !level.headshots_only && !restart )
		{
			level thread award_grenades_for_survivors();
		}
		level.round_start_time = getTime();
		while ( level.zombie_spawn_locations.size <= 0 )
		{
			wait 0.1;
		}
		wait 1; //time until zombies starts spawning
		level thread [[ level.round_spawn_func ]]();
		level notify( "start_of_round" );
		players = getplayers();
		index = 0;
		while ( index < players.size )
		{
			zonename = players[ index ] get_current_zone();
			if ( isDefined( zonename ) )
			{
				players[ index ] recordzombiezone( "startingZone", zonename );
			}
			index++;
		}
		if ( isDefined( level.round_start_custom_func ) )
		{
			[[ level.round_start_custom_func ]]();
		}
		[[ level.round_wait_func ]]();
		level.first_round = 0;
		level notify( "end_of_round" );
		//level.round_number = 1000;
		level thread maps\mp\zombies\_zm_audio::change_zombie_music( "round_end" );
		players = get_players();
		if ( isDefined( level.no_end_game_check ) && level.no_end_game_check )
		{
			level thread last_stand_revive();
			level thread spectators_respawn();
		}
		else
		{
			if ( players.size != 1 )
			{
				level thread spectators_respawn();
			}
		}
		players = get_players();
		array_thread( players, maps\mp\zombies\_zm_pers_upgrades_system::round_end );
		timer = level.zombie_vars[ "zombie_spawn_delay" ];
		if ( timer > 0.08 )
		{
			level.zombie_vars[ "zombie_spawn_delay" ] = timer * 0.95;
		}
		else
		{
			if ( timer < 0.08 )
			{
				level.zombie_vars[ "zombie_spawn_delay" ] = 0.08;
			}
		}
		level.round_number++;
		level thread flashroundnumber(); //changed back for release
		level round_over();
		level notify( "between_round_over" );
		restart = 0;
		wait .05;
	}
}


flashroundnumber()
{
	level.hud fadeovertime( 1 );
	level.hud.alpha = 0;
	wait 1.2; //og 1 
    level.hud.color = ( 0.45, 0, 0 );
	level.hud settext(  level.round_number );

    level.hud.x = 0;
    level.hud.y = -80;
    level.hudtext.x = 0;
    level.hudtext.y = -120;

	//level.hud.fontscale = 3;
	level.hud fadeovertime( 1.5 );
	level.hudtext fadeovertime( 1.5 );
    level.hud.alpha = 1;
	level.hudtext.alpha = 1; //1;
	wait 5;
	level.hudtext fadeovertime( 1 );
	level.hudtext.alpha = 0;
	wait 1.1;
	level.hud moveovertime( 1 );
	level.hud.x = 307.5;
	level.hud.y = 200;
    wait 2;
    level.hud fadeOverTime( 0.5 );
    level.hud.alpha = 0;
    wait 1;
    level.hud.color = ( 0.65, 0.65, 0.65 );
    level.hud settext( level.round_number );
    level.hud fadeovertime( 0.5 );
    level.hud.alpha = 1;
    wait 1;
}

staticPhaseText()
{
    self endon( "disconnect" );

    self waittill( "spawned_player" );

    self.phase = newClientHudElem( self );
    self.phase.color = ( 1, 1, 1 );
    self.phase settext("Phase");
    self.phase.fontscale = 1.3;
    self.phase.alpha = 0;
    self.phase fadeovertime( 2.5 );
    self.phase.alpha = 0.85;//0.8; //changed back for release

    self.phase.alignx = "center";
    self.phase.aligny = "center";

    self.phase.horzalign = "user_center";
    self.phase.vertalign = "user_center";

    self.phase.x = -65;
    self.phase.y = -20;

    self waittill( "remove_static" );
    self.phase.alpha = 0;
    
}
round_pause( delay ) //from zm-gsc, might use later
{
	if ( !isDefined( delay ) )
	{
		delay = 30;
	}
	level.countdown_hud = create_counter_hud();
	level.countdown_hud setvalue( delay );
	level.countdown_hud.color = ( 0.8, 0, 0 );
	level.countdown_hud.alpha = 1;
    level.countdown_hud.x = 0;
    level.countdown_hud.y = 0;

	level.countdown_hud fadeovertime( 2 );
	wait 2;
	level.countdown_hud.color = vectorScale( ( 1, 0, 0 ), 0.21 );
	level.countdown_hud fadeovertime( 3 );
	wait 3;
	while ( delay >= 1 )
	{
		wait 1;
		delay--;
		level.countdown_hud setvalue( delay );
	}
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] playlocalsound( "zmb_perks_packa_ready" );
	}
	level.countdown_hud fadeovertime( 1 );
	level.countdown_hud.color = ( 0, 0, -1 );
	level.countdown_hud.alpha = 0;
	wait 1;
	level.countdown_hud destroy_hud();
}



player_set_buildable_piece( piece, slot )
{
    if ( !isdefined( slot ) )
        slot = 0;

/#
    if ( isdefined( slot ) && isdefined( piece ) && isdefined( piece.buildable_slot ) )
        assert( slot == piece.buildable_slot );
#/

    if ( !isdefined( self.current_buildable_pieces ) )
        self.current_buildable_pieces = [];

    self.current_buildable_pieces[slot] = piece;
}


c_player_set_buildable_piece( piece, slot )
{
    if( !isdefined( slot ) )
    {
        slot = 0;
    }
    if( !isdefined( self.current_buildable_pieces ) )
    {
        self.current_buildable_pieces = [];
    }
    self.current_buildable_pieces[ self.current_buildable_pieces[ self.current_buildable_pieces.size ] ] = piece;
}