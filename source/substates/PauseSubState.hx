package substates;


import backend.Difficulty;
import backend.MusicBeatState;
import backend.WeekData;
import backend.Highscore;
import backend.Song;

import states.editors.ChartingState;
import states.FreeplayState;
import states.StoryMenuState;

//import options.OptionsMenu;
import options.OptionsState;

import flixel.util.FlxStringUtil;
import flixel.addons.transition.FlxTransitionableState;
import openfl.utils.Assets;

/*
    PauseSubState made by TieGuo, code optimized by Beihu.
    it used at NF Engine
    有一说一我感觉就是在屎山上加屎山，很无语 --beihu
    别骂了 -- TieGuo
*/

class PauseSubState extends MusicBeatSubstate
{

    var filePath:String = 'menuExtend/PauseState/';
    var font:String = Assets.getFont("assets/fonts/montserrat.ttf").fontName;

    var back:FlxSprite;
    var backShadow:FlxSprite;
    var front:FlxSprite;
    var backButton:FlxSprite;
    var blackback:FlxSprite;
    
    var blackbackTween:FlxTween;
    var backTween:FlxTween;
    var backShadowTween:FlxTween;
    var frontTween:FlxTween;
    
    var missingText:FlxText;
    var missingTextTimer:FlxTimer;
    var missingTextTween:FlxTween;
    var boolText:FlxText;
    
    var cheatingText:FlxText;
    var songText:FlxText;
    var dataText:FlxText;
    var practiceText:FlxText;
    var botText:FlxText;
    var ballText:FlxText;
    var menuText:Array<FlxText> = [];
    var menuTextStart:FlxTimer;
    var menuTextTween:Array<FlxTween> = [];
    
    var pauseMusic:FlxSound;
    public static var songName:String = '';
    
    var holdTime:Float = 0;
    var skipTimeText:FlxText;
    var curTime:Float = Math.max(0, Conductor.songPosition);
    
    public static var goToOptions:Bool = false; //work for open option 
	public static var goToGameplayChangers:Bool = false; // work for open GameplayChangers 
	public static var goBack:Bool = false; //work for close option or GameplayChangers then open pause state
    public static var reOpen:Bool = false; // change bg alpha fix    //修改，换成(变量)
    
    public static var curOptions:Bool = false; // curSelected fix
	public static var curGameplayChangers:Bool = false; // curSelected fix

    var stayinMenu:String = 'isChanging'; // base, difficulty, debug, isChanging or options
    // isChanging = in transition animation

    var options:Array<String> = ['Continue', 'Restart', 'Difficulty', 'Debug', 'Editor', 'Options', 'Exit'];
    var optionsAlphabet:Array<FlxText> = [];
    var optionsBars:Array<FlxSprite> = [];
    var curSelected:Int = 0;
        
    var difficultyChoices = [];
    var difficultyCurSelected:Int = 0;
    var difficultyAlphabet:Array<FlxText> = [];
    var difficultyBars:Array<FlxSprite> = [];

    var debugType:Array<String> = ['Leave', 'Practice', 'Botplay', 'Back'];
    var debugCurSelected:Int = 0;
    var debugAlphabet:Array<FlxText> = [];
    var debugBars:Array<FlxSprite> = [];

    var optionsType:Array<String> = ['Instant', 'Entirety', 'Back'];
    var optionsCurSelected:Int = 0;
    var optionsOptionsAlphabet:Array<FlxText> = [];
    var optionsOptionsBars:Array<FlxSprite> = [];

    var menuColor:Array<Int> = [
    	0xFFFF26C0,
    	0xFFAA0044,
    	0xFFFF2E00,
    	0xFFFF7200,
    	0xFFE9FF00,
    	0xFF00FF8C,
    	0xFF00B2FF,
    	0xFF3C00C9
    ];
	
    var menuShadowColor:Array<Int> = [
    	0xFFCA0083,
    	0xFF77002F,
    	0xFFBF2300,
    	0xFFBF5600,
    	0xFFE0ED55,
    	0xFF00BF69,
    	0xFF0085BF,
    	0xFF25007C
    ];
    //紫→酒红→红→橙→黄→青→蓝→深蓝→紫
    //渐变暂停界面

    var curColor:Int = 0;
    var curColorAgain:Int = 0;
    var colorTween:FlxTween;
    var colorTweenShadow:FlxTween;

    public function new(x:Float, y:Float)
	{
	    super();
    	cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	    
	    FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
    	pauseMusic = new FlxSound();
    	if(songName != null) {
    		pauseMusic.loadEmbedded(Paths.music(songName), true, true);
    	} else if (songName != 'None') {
    		pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), true, true);
    	}
    	pauseMusic.volume = 0;
    	FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
    	pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

    	FlxG.sound.list.add(pauseMusic);
	
    	blackback = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    	add(blackback);
    	blackback.alpha = 0;
    	blackbackTween = FlxTween.tween(blackback, {alpha: 0.5}, 0.75, {ease: FlxEase.quartOut});
	
    	backShadow = new FlxSprite(-800).loadGraphic(Paths.image(filePath + 'backShadow'));
    	add(backShadow);
    	backShadow.updateHitbox();
    	backShadowTween = FlxTween.tween(backShadow, {x: 0}, 1, {ease: FlxEase.quartOut});
	
    	back = new FlxSprite(-800).loadGraphic(Paths.image(filePath + 'back'));
    	add(back);
    	back.updateHitbox();
    	backTween = FlxTween.tween(back, {x: 0}, 1, {ease: FlxEase.quartOut});
	
    	front = new FlxSprite(-800).loadGraphic(Paths.image(filePath + 'front'));
    	add(front);
    	front.updateHitbox();
    	frontTween = FlxTween.tween(front, {x: 0}, 1.3, {ease: FlxEase.quartOut});
	
    	backButton = new FlxSprite(1080, 600).loadGraphic(Paths.image(filePath + 'backButton'));
    	add(backButton);
    	backButton.scale.set(0.45, 0.45);
    	backButton.updateHitbox();
    	backButton.alpha = 0;
    	#if android backButton.y -= 127; #end
	
    	if (Difficulty.list.length < 2) options.remove('Difficulty');
	
    	for (i in 0...Difficulty.list.length) {
    		var diff:String = Difficulty.getString(i);
    		difficultyChoices.push(diff);
    	}
    	difficultyChoices.push('Back');
    	
    	for (i in 0...difficultyChoices.length) {
    		var optionText:FlxText = new FlxText(0, 0, 0, difficultyChoices[i], 50);
		
    		optionText.x = -1000;
    		optionText.y = (i - difficultyCurSelected) * 180 + 325;
    		optionText.setFormat(font, 50, FlxColor.BLACK);
    		if (optionText.width > 300)
    			optionText.scale.set(300 / optionText.width, 300 / optionText.width);
    		optionText.updateHitbox();
    		difficultyAlphabet.push(optionText);
		
    		var barShadow:FlxSprite = new FlxSprite().loadGraphic(Paths.image(filePath + 'barShadow'));
    		add(barShadow);
    		barShadow.scale.set(0.5, 0.5);
    		barShadow.x = -1000;
    		barShadow.y = optionText.y - 30;
    		barShadow.updateHitbox();
    		difficultyBars.push(barShadow);
		
    		var bar:FlxSprite = new FlxSprite().loadGraphic(Paths.image(filePath + 'bar'));
    		add(bar);
    		bar.scale.set(0.5, 0.5);
    		bar.x = -1000;
    		bar.y = optionText.y - 30;
    		bar.updateHitbox();
    		difficultyBars.push(bar);
		
    		add(optionText);
    	}
    	
    	if(!PlayState.instance.startingSong)
		    debugType.insert(1, 'Skip Time');
	
    	for (i in 0...debugType.length) {
    		var optionText:FlxText = new FlxText(0, 0, 0, debugType[i], 50);
		
    		optionText.x = -1000;
    		optionText.y = (i - debugCurSelected) * 180 + 325;
    		optionText.setFormat(font, 50, FlxColor.BLACK);
    		debugAlphabet.push(optionText);
		
    		var barShadow:FlxSprite = new FlxSprite().loadGraphic(Paths.image(filePath + 'barShadow'));
    		add(barShadow);
    		barShadow.scale.set(0.5, 0.5);
    		barShadow.x = -1000;
    		barShadow.y = optionText.y - 30;
    		barShadow.updateHitbox();
    		debugBars.push(barShadow);
		
    		var bar:FlxSprite = new FlxSprite().loadGraphic(Paths.image(filePath + 'bar'));
    		add(bar);
    		bar.scale.set(0.5, 0.5);
    		bar.x = -1000;
    		bar.y = optionText.y - 30;
    		bar.updateHitbox();
    		debugBars.push(bar);
		
    		add(optionText);
    	}
	
    	for (i in 0...optionsType.length) {
    		var optionText:FlxText = new FlxText(0, 0, 0, optionsType[i], 50);
		
    		optionText.x = -1000;
    		optionText.y = (180 * (i - (optionsType.length / 2))) + 400;
    		optionText.setFormat(font, 50, FlxColor.BLACK);
    		optionsOptionsAlphabet.push(optionText);
		
    		var barShadow:FlxSprite = new FlxSprite().loadGraphic(Paths.image(filePath + 'barShadow'));
    		add(barShadow);
    		barShadow.scale.set(0.5, 0.5);
    		barShadow.x = -1000;
    		barShadow.y = optionText.y - 30;
    		barShadow.updateHitbox();
    		optionsOptionsBars.push(barShadow);
		
    		var bar:FlxSprite = new FlxSprite().loadGraphic(Paths.image(filePath + 'bar'));
    		add(bar);
    		bar.scale.set(0.5, 0.5);
    		bar.x = -1000;
    		bar.y = optionText.y - 30;
    		bar.updateHitbox();
    		optionsOptionsBars.push(bar);
		
    		add(optionText);
    	}
    	
    	if (!PlayState.chartingMode)
			options.remove('Debug');
	
    	for (i in 0...options.length) {
    		var optionText:FlxText = new FlxText(0, 0, 0, options[i], 50);
		
    		optionText.x = -1000;
    		optionText.y = (i - curSelected) * 180 + 325;
    		optionText.setFormat(font, 50, FlxColor.BLACK);
    		optionsAlphabet.push(optionText);
		
    		var barShadow:FlxSprite = new FlxSprite().loadGraphic(Paths.image(filePath + 'barShadow'));
    		add(barShadow);
    		barShadow.scale.set(0.5, 0.5);
    		barShadow.x = -1000;
    		barShadow.y = optionText.y - 30;
    		barShadow.updateHitbox();
    		optionsBars.push(barShadow);
		
    		var bar:FlxSprite = new FlxSprite().loadGraphic(Paths.image(filePath + 'bar'));
    		add(bar);
    		bar.scale.set(0.5, 0.5);
    		bar.x = -1000;
    		bar.y = optionText.y - 30;
    		bar.updateHitbox();
    		optionsBars.push(bar);
    		
    		add(optionText);
    	}
	
    	missingText = new FlxText(0, 720, 0, '', 35);
    	missingText.setFormat(font, 24, FlxColor.WHITE, 'CENTER', null, FlxColor.BLACK);
    	add(missingText);
	
    	boolText = new FlxText(0, 720, 0, 'OFF', 24);
    	boolText.setFormat(font, 24, FlxColor.BLACK);
    	add(boolText);
	
    	skipTimeText = new FlxText(0, 720, 0, '', 24);
    	skipTimeText.setFormat(font, 40, FlxColor.WHITE);
    	add(skipTimeText);
    	updateSkipTimeText();
    	
    	/*var textString:String = Date.now().toString() + '\n' +
    	'Song: ' + PlayState.SONG.song + ' - ' + Difficulty.getString().toUpperCase() + '\n' +
    	'Blueballed' + PlayState.deathCounter + '\n' + 
    	(PlayState.instance.practiceMode ? 'Practice: ON\n' : '') +
    	(PlayState.instance.cpuControlled ? 'Botplay: ON\n' : '') +
    	(PlayState.chartingMode ? 'Cheating: ON');*/
    	
    	dataText = new FlxText(0, 15, 0, Date.now().toString(), 32);
		dataText.setFormat(font, 25);
		dataText.updateHitbox();
		add(dataText);
		
		songText = new FlxText(0, 15, 0, PlayState.SONG.song + ' - ' + Difficulty.getString().toUpperCase(), 32);
		songText.setFormat(font, 25);
		songText.updateHitbox();
		add(songText);
		
		ballText = new FlxText(0, 15, 0, 'Blueballed: ' + PlayState.deathCounter, 32);
		ballText.setFormat(font, 25);
		ballText.updateHitbox();
		add(ballText);
		
		practiceText = new FlxText(0, 15, 0, 'Practice Mode: ' + (PlayState.instance.practiceMode ? 'ON' : 'OFF'), 32);
		practiceText.setFormat(font, 25);
		practiceText.updateHitbox();
		add(practiceText);
		
		botText = new FlxText(0, 15, 0, 'Botplay: ' + (PlayState.instance.cpuControlled ? 'ON' : 'OFF'), 32);
		botText.setFormat(font, 25);
		botText.updateHitbox();
		add(botText);
		
		cheatingText = new FlxText(0, 15, 0, 'Cheating: ' + (PlayState.chartingMode ? 'ON' : 'OFF'), 32);
		cheatingText.setFormat(font, 25);
		cheatingText.updateHitbox();
		add(cheatingText);
		
		menuText = [dataText, songText, ballText, practiceText, botText, cheatingText];
		
		var curText = 0;
		for (i in menuText)
		{
			i.alpha = 0;
			i.x = 1280 + 200;
		}
		
		menuTextStart = new FlxTimer().start(0.1, function(tmr:FlxTimer) {//改
    		//menuTextTween[curText * 2] = FlxTween.tween(menuText[curText], {x: 1280 - 15 - menuText[curText].width}, 0.2, {ease: FlxEase.quartIn});
    		menuText[curText].alpha = 0;
    		menuTextTween[curText] = FlxTween.tween(menuText[curText], {alpha: 1}, 0.2, {ease: FlxEase.quartIn});
    		menuText[curText].y =  7.5 + (menuText[curText].height)*curText;
    		curText++;
    	}, menuText.length);
    	
    	new FlxTimer().start(0.4, function(tmr:FlxTimer) {
    		stayinMenu = 'base';
    		changeOptions(0);
    	});
    	
    	changeMenuColor();
    	
    	new FlxTimer().start(2, function(tmr:FlxTimer) {
    		changeMenuColor();
    	}, 0);
    	
    	#if android
		    if (PlayState.chartingMode)addVirtualPad(PauseSubstate, A);
		    else addVirtualPad(UP_DOWN, A);
		    addPadCamera();
		#end
    }

    override function update(elapsed:Float) {
        
        if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;
        super.update(elapsed);
        
        dataText.text = Date.now().toString();
		
		songText.text = PlayState.SONG.song + ' - ' + Difficulty.getString().toUpperCase();
		
		ballText.text = 'Blueballed: ' + PlayState.deathCounter;
		
		practiceText.text = 'Practice Mode: ' + (PlayState.instance.practiceMode ? 'ON' : 'OFF');
		
		botText.text = 'Botplay: ' + (PlayState.instance.cpuControlled ? 'ON' : 'OFF');

		cheatingText.text = 'Cheating: ' + (PlayState.chartingMode ? 'ON' : 'OFF');
		
		
		for (i in menuText)
		{
			i.x = 1280 -15 -i.width;
		}
		
        
        var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var leftP = controls.UI_LEFT_P;
		var rightP = controls.UI_RIGHT_P;
		var accept = controls.ACCEPT;
		
    	switch (stayinMenu) {
        	case 'base':
        		for (i in 0...options.length) {
        			optionsAlphabet[i].x = FlxMath.lerp((curSelected - i)*45.5 + 100 + (i == curSelected ? 75 : 0), optionsAlphabet[i].x, FlxMath.bound(1 - (elapsed * 8.5), 0, 1));
        			optionsAlphabet[i].y = FlxMath.lerp((i - curSelected) * 180 + 325, optionsAlphabet[i].y, FlxMath.bound(1 - (elapsed * 8.5), 0, 1));
        			
        			optionsBars[i*2].x = optionsAlphabet[i].x - 300;
        			optionsBars[i*2].y = optionsAlphabet[i].y - 30;
        			
        			optionsBars[i*2+1].x = optionsAlphabet[i].x - 300;
        			optionsBars[i*2+1].y = optionsAlphabet[i].y - 30;
        		}
        	case 'debug':
        		for (i in 0...debugType.length) {
        			debugAlphabet[i].x = FlxMath.lerp((debugCurSelected - i) * 45.5 + 100 + (i == debugCurSelected ? 75 : 0), debugAlphabet[i].x, FlxMath.bound(1 - (elapsed * 8.5), 0, 1));
        			debugAlphabet[i].y = FlxMath.lerp((i - debugCurSelected) * 180 + 325, debugAlphabet[i].y, FlxMath.bound(1 - (elapsed * 8.5), 0, 1));
    			
        			debugBars[i*2].x = debugAlphabet[i].x - 300;
        			debugBars[i*2].y = debugAlphabet[i].y - 30;
    			
        			debugBars[i*2+1].x = debugAlphabet[i].x - 300;
        			debugBars[i*2+1].y = debugAlphabet[i].y - 30;
        		}
    		
        		var text = debugAlphabet[debugCurSelected];
        		if ((text.text == 'Botplay' || text.text == 'Practice') && stayinMenu == 'debug')
        		{
        			boolText.x = text.x + text.width + 5;
        			boolText.y = text.y;
        		} else
        			boolText.y = 1000;
    			
        		if (text.text == 'Skip Time' && stayinMenu == 'debug') {
        			skipTimeText.x = text.x + text.width + 125;
        			skipTimeText.y = text.y + 7.5;
        			if (leftP)
        			{
        				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
        				curTime -= 1000;
        				holdTime = 0;
        			}
        			if (rightP)
        			{
        				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
        				curTime += 1000;
        				holdTime = 0;
        			}
    
        			if(controls.UI_LEFT || controls.UI_RIGHT)
        			{
        				holdTime += elapsed;
        				if(holdTime > 0.5)
        				{
        					curTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
        				}
    
        				if(curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
        				else if(curTime < 0) curTime += FlxG.sound.music.length;
        				updateSkipTimeText();
        			}
        		} else
        			skipTimeText.y = 1000;
        	case 'difficulty':
        		for (i in 0...difficultyAlphabet.length) {
                    difficultyAlphabet[i].x = FlxMath.lerp((difficultyCurSelected - i) * 45.5 + 100 + (i == difficultyCurSelected ? 75 : 0), difficultyAlphabet[i].x, FlxMath.bound(1 - (elapsed * 8.5), 0, 1));
        			difficultyAlphabet[i].y = FlxMath.lerp((i - difficultyCurSelected) * 180 + 325, difficultyAlphabet[i].y, FlxMath.bound(1 - (elapsed * 8.5), 0, 1));
        			
        			difficultyBars[i*2].x = difficultyAlphabet[i].x - 300;
        			difficultyBars[i*2].y = difficultyAlphabet[i].y - 30;
    			
        			difficultyBars[i*2+1].x = difficultyAlphabet[i].x - 300;
        			difficultyBars[i*2+1].y = difficultyAlphabet[i].y - 30;
        		}
        	case 'options':
        		for (i in 0...optionsOptionsAlphabet.length) {
        				
        			optionsOptionsAlphabet[i].x = FlxMath.lerp(-i *45.5 + 45.5 + 100 + (i == optionsCurSelected ? 75 : 0), optionsOptionsAlphabet[i].x, FlxMath.bound(1 - (elapsed * 8.5), 0, 1));
        			optionsOptionsAlphabet[i].y = FlxMath.lerp((180 * (i - (optionsOptionsAlphabet.length / 2))) + 400, optionsOptionsAlphabet[i].y, FlxMath.bound(1 - (elapsed * 8.5), 0, 1));
        			
        			optionsOptionsBars[i*2].x = optionsOptionsAlphabet[i].x - 300;
        			optionsOptionsBars[i*2].y = optionsOptionsAlphabet[i].y - 30;
        			
        			optionsOptionsBars[i*2+1].x = optionsOptionsAlphabet[i].x - 300;
        			optionsOptionsBars[i*2+1].y = optionsOptionsAlphabet[i].y - 30;
        		}
    	}
    		
		if (upP)
			changeOptions(-1);
		else if (downP)
			changeOptions(1);
		
	    if (accept)
    		doEvent();
    }

    function changeOptions(num:Int) {
    	switch (stayinMenu) {
        	case 'base':
        		curSelected += num;
        		if (curSelected > options.length - 1) curSelected = 0;
        		if (curSelected < 0) curSelected = options.length - 1;
        		
        		for (i in optionsAlphabet) i.alpha = 0.5;
        		
        		optionsAlphabet[curSelected].alpha = 1;
        	case 'debug':
        		debugCurSelected += num;
        		if (debugCurSelected > debugType.length - 1) debugCurSelected = 0;
        		if (debugCurSelected < 0) debugCurSelected = debugType.length - 1;
        		
        		for (i in debugAlphabet) i.alpha = 0.5;
        		
        		debugAlphabet[debugCurSelected].alpha = 1;
        		
        		var text = debugAlphabet[debugCurSelected];
        		if (text.text == 'Botplay' || text.text == 'Practice')
        		{
        			boolText.text = (text.text == 'Botplay' ? (PlayState.instance.cpuControlled ? 'ON' : 'OFF') : (PlayState.instance.practiceMode ? 'ON' : 'OFF'));
        		}
        	case 'difficulty':
        		difficultyCurSelected += num;
        		if (difficultyCurSelected > difficultyChoices.length - 1) difficultyCurSelected = 0;
        		if (difficultyCurSelected < 0) difficultyCurSelected = difficultyChoices.length - 1;
        		
        		for (i in difficultyAlphabet) i.alpha = 0.5;
        		
        		difficultyAlphabet[difficultyCurSelected].alpha = 1;
        	case 'options':
        		optionsCurSelected += num;
        		if (optionsCurSelected > optionsType.length - 1) optionsCurSelected = 0;
        		if (optionsCurSelected < 0) optionsCurSelected = optionsType.length - 1;
        		
        		for (i in optionsOptionsAlphabet) i.alpha = 0.5;
        		
        		optionsOptionsAlphabet[optionsCurSelected].alpha = 1;
    	}
    	
    	if (num != 0)
    		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
    }

    function doEvent() {
    	if (stayinMenu == 'base') {
    		var daChoice:String = options[curSelected];
    		switch (daChoice) {
        		case 'Difficulty':
        			for (i in optionsBars)
        				FlxTween.tween(i, {x: -1000}, 0.5, {ease: FlxEase.quartIn});
        				
        			for (i in optionsAlphabet)
        				FlxTween.tween(i, {x: -1000}, 0.5, {ease: FlxEase.quartIn});
        				
        			stayinMenu = 'isChanging';
        			setBackButton(false);
        			new FlxTimer().start(0.5, function(tmr:FlxTimer) {
        				stayinMenu = 'difficulty';
        				changeOptions(0);
        			});
        		case 'Debug':
        			for (i in optionsBars)
        				FlxTween.tween(i, {x: -1000}, 0.5, {ease: FlxEase.quartIn});
    				
        			for (i in optionsAlphabet)
        				FlxTween.tween(i, {x: -1000}, 0.5, {ease: FlxEase.quartIn});
    			
        			stayinMenu = 'isChanging';
        			setBackButton(false);
        			new FlxTimer().start(0.5, function(tmr:FlxTimer) {
        				stayinMenu = 'debug';
        				changeOptions(0);
        				changeOptions(0);
        			});
    			
        			PlayState.chartingMode = true;
        		case 'Options':
        			for (i in optionsBars)
        				FlxTween.tween(i, {x: -1000}, 0.5, {ease: FlxEase.quartIn});
    				
        			for (i in optionsAlphabet)
        				FlxTween.tween(i, {x: -1000}, 0.5, {ease: FlxEase.quartIn});
    			
        			stayinMenu = 'isChanging';
        			setBackButton(false);
        			new FlxTimer().start(0.5, function(tmr:FlxTimer) {
        				stayinMenu = 'options';
        				changeOptions(0);
        			});
        		case 'Continue':
        			for (i in optionsBars)
        				FlxTween.tween(i, {x: -1000}, 0.5, {ease: FlxEase.quartIn});
    				
        			for (i in optionsAlphabet)
        				FlxTween.tween(i, {x: -1000}, 0.5, {ease: FlxEase.quartIn});
        				
        			var curText = 0;
        			
        			if (menuTextStart != null) menuTextStart.cancel();
    				new FlxTimer().start(0.1, function(tmr:FlxTimer) {
    				    if (menuTextTween[curText] != null) menuTextTween[curText].cancel();
    				    //if (menuTextTween[curText * 2 + 1] != null) menuTextTween[curText * 2 + 1].cancel();				        				        	    
    				    
        				//menuTextTween[curText * 2] = FlxTween.tween(menuText[menuText.length-curText-1], {x: 1280 + menuText[curText].width}, 0.2, {ease: FlxEase.quartIn});
        				menuTextTween[curText] = FlxTween.tween(menuText[menuText.length-curText-1], {alpha: 0}, 0.2, {ease: FlxEase.quartIn});
        				curText++;
        			}, menuText.length);
    			    
        			stayinMenu = 'isChanging';
    			    
    			    FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);			   
    			    
    			    if (blackbackTween != null && backShadowTween != null && backTween != null && frontTween != null){
                        blackbackTween.cancel();
    			        backShadowTween.cancel();
                        backTween.cancel();
    			        frontTween.cancel();
    			    }
    			    
    			    blackbackTween = FlxTween.tween(blackback, {alpha: 0}, 0.75, {ease: FlxEase.quartOut});
        			backShadowTween = FlxTween.tween(backShadow, {x: -800}, 1, {ease: FlxEase.quartIn});
        			backTween = FlxTween.tween(back, {x: -800}, 1, {ease: FlxEase.quartIn});
        			frontTween = FlxTween.tween(front, {x: -800}, 0.75, {ease: FlxEase.quartIn});    			    
        			
        			
        			new FlxTimer().start(1, function(tmr:FlxTimer) {
        				close();
        			});
        		case 'Restart':
        			restartSong();
        		case 'Exit':
        			PlayState.deathCounter = 0;
        			PlayState.seenCutscene = false;
    
        			Mods.loadTopMod();
        			if(PlayState.isStoryMode) {
        				MusicBeatState.switchState(new StoryMenuState());
        			} else {
        				MusicBeatState.switchState(new FreeplayState());
        			}
        			PlayState.cancelMusicFadeTween();
        			FlxG.sound.playMusic(Paths.music('freakyMenu'));
        			PlayState.changedDifficulty = false;
        			PlayState.chartingMode = false;
        			FlxG.camera.followLerp = 0;
        		case 'Editor':
        			MusicBeatState.switchState(new ChartingState());
        			PlayState.chartingMode = true;
    		}
    	} else if (stayinMenu == 'debug') {
    		var daChoice:String = debugType[debugCurSelected];
    		switch (daChoice) {
        		case 'Botplay':
        			PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
        			PlayState.changedDifficulty = true;
        			PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
        			PlayState.instance.botplayTxt.alpha = 1;
        			PlayState.instance.botplaySine = 0;
        			boolText.text = (PlayState.instance.cpuControlled ? 'ON' : 'OFF');
        		case 'Practice':
        			PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
        			PlayState.changedDifficulty = true;
        			boolText.text = (PlayState.instance.practiceMode ? 'ON' : 'OFF');
            	case 'Skip Time':
        			if(curTime < Conductor.songPosition)
        			{
        	    			PlayState.startOnTime = curTime;
        					restartSong(true);
        			}
        			else
        			{
        				if (curTime != Conductor.songPosition)
        				{
        					PlayState.instance.clearNotesBefore(curTime);			
        					PlayState.instance.setSongTime(curTime);
        				}
        				close();
        			}
        		case 'Leave':
        			restartSong();
    				PlayState.chartingMode = false;
        		case 'Back':
        			for (i in debugBars)
        				FlxTween.tween(i, {x: -1000}, 0.5, {ease: FlxEase.quartIn});
    				
        			for (i in debugAlphabet)
        				FlxTween.tween(i, {x: -1000}, 0.5, {ease: FlxEase.quartIn});
        			
        			stayinMenu = 'isChanging';
        			setBackButton(true);
        			new FlxTimer().start(0.5, function(tmr:FlxTimer) {
        				stayinMenu = 'base';
        				for (i in debugAlphabet)
        				i.y += (debugAlphabet.length - 1) * 180;
        				debugCurSelected = 0;
        				changeOptions(0);
        			});
        			FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
    		}
    	} else if (stayinMenu == 'options') {
			switch (optionsType[optionsCurSelected]) {
    			case 'Instant':
        			PlayState.instance.paused = true; // For lua
        			PlayState.instance.vocals.volume = 0;
        			OptionsState.onPlayState = true;
        			if(ClientPrefs.data.pauseMusic != 'None'){
        				FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), pauseMusic.volume);
        				FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
        			    FlxG.sound.music.time = pauseMusic.time;
        			}
        			MusicBeatState.switchState(new OptionsState());
        		case 'Entirety':
        			close();
        			//openSubState(new optionsMenu());
        		case 'Back':
        			for (i in optionsOptionsBars)
        				FlxTween.tween(i, {x: -1000}, 0.5, {ease: FlxEase.quartIn});
        				
        			for (i in optionsOptionsAlphabet)
        				FlxTween.tween(i, {x: -1000}, 0.5, {ease: FlxEase.quartIn});
        			
        			stayinMenu = 'isChanging';
        			setBackButton(true);
        			new FlxTimer().start(0.5, function(tmr:FlxTimer) {
    					stayinMenu = 'base';
    					optionsCurSelected = 0;
    					changeOptions(0);
        			});
        			
        			FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
    		}
    	} else if (stayinMenu == 'difficulty') {
    		if (difficultyChoices[difficultyCurSelected] == 'Back') {
    			for (i in difficultyBars)
    				FlxTween.tween(i, {x: -1000}, 0.5, {ease: FlxEase.quartIn});
				
    			for (i in difficultyAlphabet)
    				FlxTween.tween(i, {x: -1000}, 0.5, {ease: FlxEase.quartIn});
			
    			stayinMenu = 'isChanging';
    			setBackButton(true);
    			new FlxTimer().start(0.5, function(tmr:FlxTimer) {
    				stayinMenu = 'base';
    				for (i in difficultyAlphabet)
    				i.y += (difficultyAlphabet.length - 1) * 180;
    				difficultyCurSelected = 0;
    				changeOptions(0);
    			});
    			FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
    			return;
    		}
	        try{
        		var name:String = PlayState.SONG.song;
        		var poop = Highscore.formatSong(name, difficultyCurSelected);
        		PlayState.SONG = Song.loadFromJson(poop, name);
           		PlayState.storyDifficulty = difficultyCurSelected;
        		MusicBeatState.resetState();
        		FlxG.sound.music.volume = 0;
        		PlayState.changedDifficulty = true;
        		PlayState.chartingMode = false;
        	} catch(e:Dynamic) {
        		missingText.text = 'ERROR WHILE LOADING CHART: ' + PlayState.SONG.song + '-' + difficultyChoices[difficultyCurSelected];
        		missingText.screenCenter(X);
        		FlxG.sound.play(Paths.sound('cancelMenu'));

        	    
        		
        		if (missingTextTimer == null && missingTextTween != null) {
        			missingTextTween = FlxTween.tween(missingText, {y: 680}, 0.5, {ease: FlxEase.quartOut});
        	    	missingTextTimer = new FlxTimer().start(2, function(tmr:FlxTimer) {
    		    	missingTextTween = FlxTween.tween(missingText, {y: 720}, 0.5, {ease: FlxEase.quartIn});
    	        		missingTextTimer = null;
    	        		missingTextTween = null;
                	}, 1);
                }
    	    }
        }
    }
    
    function setBackButton(hide:Bool) {
	    if (hide) {
    		FlxTween.tween(backButton, {alpha: 0}, 0.5, {ease: FlxEase.quartIn});
    		FlxTween.tween(backButton, {x: 1100}, 0.5, {ease: FlxEase.quartIn});
    	} else {
    		FlxTween.tween(backButton, {alpha: 1}, 0.5, {ease: FlxEase.quartIn});
    		FlxTween.tween(backButton, {x: 1080}, 0.5, {ease: FlxEase.quartIn});
	    }
    }

    override function destroy()
    {
    	pauseMusic.destroy();
    	if (colorTween != null && colorTweenShadow != null)
    	{
    		colorTween.cancel();
    		colorTweenShadow.cancel();
    	}
    	
    	for (i in menuText)
		{
			i.alpha = 0;
			i.x = 1280 + 200;
		}
    }

    function changeMenuColor() {
	    if (colorTween != null && colorTweenShadow != null)
	    {
		    colorTween.cancel();
		    colorTweenShadow.cancel();
	    }
	
	    for (i in 0...Std.int(optionsBars.length/2))
		    colorTweenShadow = FlxTween.color(optionsBars[i*2], 2, optionsBars[i*2].color, menuShadowColor[curColor]);
	    for (i in 0...Std.int(debugBars.length/2))
		    colorTweenShadow = FlxTween.color(debugBars[i*2], 2, debugBars[i*2].color, menuShadowColor[curColor]);
	    for (i in 0...Std.int(difficultyBars.length/2))
    		colorTweenShadow = FlxTween.color(difficultyBars[i*2], 2, difficultyBars[i*2].color, menuShadowColor[curColor]);
    	for (i in 0...Std.int(optionsOptionsBars.length/2))
        	colorTweenShadow = FlxTween.color(optionsOptionsBars[i*2], 2, optionsOptionsBars[i*2].color, menuShadowColor[curColor]);
    	
    	colorTween = FlxTween.color(back, 2, menuColor[curColorAgain], menuColor[curColor]);
    	colorTweenShadow = FlxTween.color(backShadow, 2, menuColor[curColorAgain], menuColor[curColor]);
    	
    	curColor++;
    	curColorAgain = curColor - 1;
    	if (curColor > menuShadowColor.length -1) curColor = 0;
    	if (curColorAgain < 0) curColorAgain = menuShadowColor.length -1;
    }
	    
    public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
		}
		MusicBeatState.resetState();
	}

    function updateSkipTimeText()
    {
    	skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
    }
    
}