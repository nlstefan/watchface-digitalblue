using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.ActivityMonitor as ActivityMonitor;

class DigitalBlueView extends Ui.WatchFace {
	var imgSleepMode;
	var imgBTConnected;
	var imgAlarm;
    var margin = 10;
    var marginSmall = 5;
    var screenWidth = 0;
    var screenHeight = 0;
    var centerWidth = 0;
    var centerHeight = 0;
    
    var showSeconds = false;
    var secondsEnabled = false;
    var hasNotificationSupport = false;
    var hasAlarmSupport = false;
    var batteryPercentageEnabled = false;
    var deviceID = "undetermined";
    
    var themeWhite = false;
    var autoThemeWhite = false;
    var autoThemeFrom = 20;
    var autoThemeTo = 7;
    
    
    var textColor = Gfx.COLOR_WHITE;
    var lineColor = Gfx.COLOR_WHITE;
    var backGroundColor = Gfx.COLOR_BLACK;
    
	//! Constructor
    function initialize()
    {

        hasAlarmSupport = (Sys.getDeviceSettings() has :alarmCount ) ? true : false;
        hasNotificationSupport = (Sys.getDeviceSettings() has :notificationCount ) ? true : false;
    }
    
    function reloadResources(){
        batteryPercentageEnabled = Application.getApp().getProperty("BatteryPercentageEnabled");
   	 	secondsEnabled = Application.getApp().getProperty("SecondsEnabled");
   	 	themeWhite = Application.getApp().getProperty("WhiteThemeEnabled");
   	 	autoThemeWhite = Application.getApp().getProperty("WhiteThemeAutoEnabled");
   	 	deviceID = Ui.loadResource(Rez.Strings.deviceID);
   	 	var setting = Application.getApp().getProperty("WhiteThemeFrom");
   	 	if(setting instanceof Toybox.Lang.String) {
			setting = setting.toNumber();
		}
    	autoThemeFrom = setting;
    	
    	setting = Application.getApp().getProperty("WhiteThemeTo");
   	 	if(setting instanceof Toybox.Lang.String) {
			setting = setting.toNumber();
		}
    	autoThemeTo = setting;
   	 	
   	 	reloadTheme();
    }	
    
    function reloadTheme(){
    	if (themeWhite){
	        imgSleepMode = Ui.loadResource(Rez.Drawables.imgSleepModeThemeWhite);
	        imgBTConnected = Ui.loadResource(Rez.Drawables.imgBTConnectedThemeWhite);
	        imgAlarm = Ui.loadResource(Rez.Drawables.imgAlarmThemeWhite);
		        
		    textColor = Gfx.COLOR_BLACK;
    		lineColor = Gfx.COLOR_BLACK;
    		backGroundColor = Gfx.COLOR_WHITE;
   	 	} else {
        	imgSleepMode = Ui.loadResource(Rez.Drawables.imgSleepMode);
        	imgBTConnected = Ui.loadResource(Rez.Drawables.imgBTConnected);
        	imgAlarm = Ui.loadResource(Rez.Drawables.imgAlarm);
        	
        	textColor = Gfx.COLOR_WHITE;
    		lineColor = Gfx.COLOR_WHITE;
    		backGroundColor = Gfx.COLOR_BLACK;
        }
    }
	
    //! Load your resources here
    function onLayout(dc) {
    	reloadResources();
    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
		var clockTime = Sys.getClockTime();
		
		if (autoThemeWhite){
			var previousTheme = themeWhite;
			if (autoThemeFrom > autoThemeTo){
				if (clockTime.hour >= autoThemeFrom || clockTime.hour < autoThemeTo){
					themeWhite = true;
				} else {
					themeWhite = false;
				}
			} else {
				if (clockTime.hour >= autoThemeFrom && clockTime.hour < autoThemeTo){
					themeWhite = true;
				} else {
					themeWhite = false;
				}
			}
			
			if (previousTheme != themeWhite){
				reloadTheme();
				previousTheme = themeWhite;
			}
		}
		
		//clear screen
    	dc.setColor(backGroundColor, backGroundColor);
    	dc.clear();
        
        if (screenWidth == 0){
        	screenWidth = dc.getWidth();
        	centerWidth = (screenWidth / 2).toNumber();
        	screenHeight = dc.getHeight();
        	centerHeight = (screenHeight / 2).toNumber();
        }
        
		var dimensionsTime = drawTime(dc, centerWidth, centerHeight, clockTime, showSeconds);

    	drawDate(dc, centerWidth, 10, Time.now());
    	
    	//draw battery
		drawBattery(dc, centerWidth-15, screenHeight-25, Sys.getSystemStats().battery);
		
		//draw steps
		if(Sys.getDeviceSettings().activityTrackingOn){
        	var moveBarLevel = ActivityMonitor.getInfo().moveBarLevel;
        	var movebarProgress = (moveBarLevel.toFloat()/ActivityMonitor.MOVE_BAR_LEVEL_MAX.toFloat());
        	var stepPercentage = (ActivityMonitor.getInfo().steps.toFloat() / ActivityMonitor.getInfo().stepGoal.toFloat());
			drawStepProgress(dc,centerWidth - (dimensionsTime[0]/2) - 1, centerHeight+(dimensionsTime[1]/2)+marginSmall, dimensionsTime[0]+1, stepPercentage, movebarProgress);
		}
//		drawStepProgress(dc,10, 10, 150, 0.15, 0);
//		drawStepProgress(dc,10, 20, 150, 0.3, 0.2);
//		drawStepProgress(dc,10, 30, 150, 0.15, 0.6);
//		drawStepProgress(dc,10, 40, 150, 0.45, 1.2);
//		drawStepProgress(dc,10, 50, 150, 1, 0);
//		drawStepProgress(dc,10, 60, 150, 1.2, 0.2);
//		drawStepProgress(dc,10, 60, 150, 1.2, 0.8);
//		drawStepProgress(dc,10, 70, 150, 1.2, 1.2);
    	
    	drawBTConnected(dc, centerWidth + 20, screenHeight-25, Sys.getDeviceSettings().phoneConnected);
    	
    	if (hasNotificationSupport){
   	    	drawNotifications(dc, centerWidth + 20, screenHeight-25, Sys.getDeviceSettings().notificationCount);
    	}
    	
    	drawSleepMode(dc, centerWidth - 30, screenHeight-21, ActivityMonitor.getInfo().isSleepMode);   
    	
    	var alarmPos = centerWidth - 55;
    	if (!ActivityMonitor.getInfo().isSleepMode){
    		alarmPos = centerWidth - 40;
    	}
    	
    	if (hasAlarmSupport){
    		drawAlarm(dc, alarmPos, screenHeight-24, Sys.getDeviceSettings().alarmCount);
    	}
    }
    
    function drawDate(dc, x, y, date){
        var info = Calendar.info(date, Time.FORMAT_LONG);
        var dateString = Lang.format("$1$ $2$ $3$", [info.day_of_week, info.day, info.month]);
        var fontDate = Gfx.FONT_MEDIUM;
		var dimensionsDate = dc.getTextDimensions(dateString, fontDate);	
    	//draw date
		dc.setColor(textColor, Gfx.COLOR_TRANSPARENT);
    	dc.drawText(x, y, fontDate, dateString, Gfx.TEXT_JUSTIFY_CENTER);
    
    }
    
    function drawTime(dc, x, y, clockTime, showSeconds){
        var fontTime = Gfx.FONT_NUMBER_THAI_HOT;
        var timeString;
    	dc.setColor(textColor, Gfx.COLOR_TRANSPARENT);
        //var hourTimeString;
        if (Sys.getDeviceSettings().is24Hour){
        	timeString = Lang.format("$1$:$2$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);
        } else {
        	if (clockTime.hour > 12){
	        	var tmpHour = clockTime.hour - 12;
	        	timeString = Lang.format("$1$:$2$", [tmpHour.format("%02d"), clockTime.min.format("%02d")]);
	        }else if (clockTime.hour == 0){
	        	var tmpHour = clockTime.hour + 12;
	        	timeString = Lang.format("$1$:$2$", [tmpHour.format("%02d"), clockTime.min.format("%02d")]);
        	}else {
	        	timeString = Lang.format("$1$:$2$",[clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);
        	}
        }
         
        var dimensionsTime = dc.getTextDimensions(timeString, fontTime);
		var xLocAmPmSeconds = x + (dimensionsTime[0]/2).toNumber() + marginSmall-1;
		var timeHeight = y-(dimensionsTime[1]/2).toNumber();
		if (!Sys.getDeviceSettings().is24Hour){
			var ampmYLoc = timeHeight;
			
        	if (clockTime.hour >= 12){
        		dc.drawText(xLocAmPmSeconds, timeHeight+getFontOffsetBug(Gfx.FONT_MEDIUM), Gfx.FONT_MEDIUM, "PM", Gfx.TEXT_JUSTIFY_LEFT);
        	} else {
        		dc.drawText(xLocAmPmSeconds, timeHeight+getFontOffsetBug(Gfx.FONT_MEDIUM), Gfx.FONT_MEDIUM, "AM", Gfx.TEXT_JUSTIFY_LEFT);
        	}
        }
        
        if (secondsEnabled){
          	//dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
	        if(showSeconds){
	        	dc.drawText(xLocAmPmSeconds,timeHeight+dimensionsTime[1]-23+getFontOffsetBug(Gfx.FONT_MEDIUM), Gfx.FONT_MEDIUM, clockTime.sec.format("%02d"), Gfx.TEXT_JUSTIFY_LEFT);	
	        } else {
	        	dc.drawText(xLocAmPmSeconds,timeHeight+dimensionsTime[1]-23+getFontOffsetBug(Gfx.FONT_MEDIUM), Gfx.FONT_MEDIUM, "--", Gfx.TEXT_JUSTIFY_LEFT);	
	        }
          	//dc.setColor(textColor, Gfx.COLOR_TRANSPARENT);
        }

		//draw time
        dc.drawText(x, timeHeight, fontTime, timeString, Gfx.TEXT_JUSTIFY_CENTER);
        
        return dimensionsTime;
    }
    
    function getFontOffsetBug(font){
     	Sys.println("deviceId" + deviceID);
     if (deviceID.equals("vivoactive")){
     	Sys.println("offsetbug active");
     	if (font == Gfx.FONT_SMALL){
      		return -2;
      	} else if (font == Gfx.FONT_MEDIUM){
      		return -3;
      	} else {
      		return -2;
      	}
     } else { 
     	Sys.println("offsetbug inactive");
     	return 0;
     }
    }
    
    function drawAlarm(dc, x, y, count){
    	if (count > 0){
       		dc.drawBitmap(x, y-4, imgAlarm);
   	    }
    }
   
    function drawNotifications(dc, x, y, count){
    	dc.setPenWidth(1);
    	if (count > 0){
    		var notificationWidth=20;
    		var notificationHeight=16;
       		dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);       		
       		dc.fillRectangle(x+1, y+1, notificationWidth-2, notificationHeight-2);

       		dc.setColor(lineColor, Gfx.COLOR_TRANSPARENT);
       		dc.drawRectangle(x, y, notificationWidth, notificationHeight);
       		
       		var centerEnvelope = (x+notificationWidth/2).toNumber();
       		if (count > 1){
       			dc.drawText(centerEnvelope, y+getFontOffsetBug(Gfx.FONT_SMALL), Gfx.FONT_SMALL, count.format("%d"), Gfx.TEXT_JUSTIFY_CENTER);
       		} else {
	       		var centerHeightEnvelope = y+(notificationHeight/2).toNumber();
       			dc.drawLine(x, y, centerEnvelope, centerHeightEnvelope);
       			dc.drawLine(x+notificationWidth-1, y, centerEnvelope-1, centerHeightEnvelope);
       		}
   	    }
    }
    
    function drawSleepMode(dc, x, y, isSleepMode){
    	if(isSleepMode){
  //  		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
			dc.drawBitmap(x, y-4, imgSleepMode);
    	}
    }
    
    function drawBTConnected(dc, x, y, isBTConnected){
    	if(!isBTConnected){
    		var notificationWidth=15;
    		var notificationHeight=16;

			dc.drawBitmap(x-3, y-2, imgBTConnected);
       		dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
       		dc.setPenWidth(2);
   			dc.drawLine(x, y, x+notificationWidth, y+notificationHeight);
   			dc.drawLine(x, y+notificationHeight-1, x+notificationWidth, y-1);
    	}
    }
    
    function drawBattery(dc, x, y, batteryLevel){
    	var batteryWidth=30;
    	var batteryHeight=16;
    	
    	dc.setPenWidth(1);
    	dc.setColor(lineColor, Gfx.COLOR_TRANSPARENT);
    	dc.drawRectangle(x, y, batteryWidth-2, batteryHeight);
    	dc.drawRectangle(x+batteryWidth-2, y+3, 2, 10);
    	if (batteryLevel <=20){
    		dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
    	}else{
    		dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
    	}
    	dc.fillRectangle(x+1, y+1, (batteryWidth-4)*(batteryLevel.toFloat()/100).toFloat(), batteryHeight-2);
    	if (batteryPercentageEnabled){
    	    dc.setColor(textColor, Gfx.COLOR_TRANSPARENT);
    	    dc.drawText(x+(batteryWidth/2)-1, y+getFontOffsetBug(Gfx.FONT_SMALL), Gfx.FONT_SMALL, batteryLevel.format("%d"), Gfx.TEXT_JUSTIFY_CENTER);
    	}
    }
    
    function drawStepProgress(dc,x,y,width,stepPercentage, moveBarLevel){
		var widthWhite = 0;
		var xLocWhite = 0;
		var widthPurpleOrGreen = 0;
		var stepWidthBlue = 0;
		var xLocBlue = 0;
		var moveWidthRed = 0;
		var xLocRed = 0;
		var xLocSeparator = 0;
		var height = 4;
		
		var totalStepWidth = 0;
		if (stepPercentage < 1){	
			totalStepWidth = width * stepPercentage;
		} else {
			totalStepWidth = width;
		}
		
		var totalMoveWidth = 0;
		if (moveBarLevel < 1){	
			totalMoveWidth = width * moveBarLevel;
		} else {
			totalMoveWidth = width;
		}
		
		totalStepWidth = totalStepWidth.toNumber();
		totalMoveWidth = totalMoveWidth.toNumber();
		
		if (moveBarLevel > ActivityMonitor.MOVE_BAR_LEVEL_MIN){	
			//PAARS BLAUW ROOD EN WIT BEREKENEN
			if (totalStepWidth > totalMoveWidth){
				widthPurpleOrGreen = totalMoveWidth;
				stepWidthBlue = totalStepWidth - widthPurpleOrGreen;
				xLocBlue = x + widthPurpleOrGreen;
				if (stepPercentage < 1){
					widthWhite = width - totalStepWidth;
					xLocWhite = x + totalStepWidth;
				}
				xLocSeparator = x + widthPurpleOrGreen;
			} else {
				widthPurpleOrGreen = totalStepWidth;
				moveWidthRed = totalMoveWidth - widthPurpleOrGreen;
				xLocRed = x + widthPurpleOrGreen;
				if (stepPercentage < 1){
					widthWhite = width - totalMoveWidth;
					xLocWhite = x + totalMoveWidth;
					xLocSeparator = x + widthPurpleOrGreen;
				}
			}
		} else {
			//BLAUW EN WIT BEREKENEN
			stepWidthBlue = totalStepWidth;
			widthWhite = width-totalStepWidth;
			xLocWhite = x + totalStepWidth;
			xLocBlue = x;
		}
		
		
		//TEKENEN
		if (widthPurpleOrGreen > 0){
			if (stepPercentage < 1){
				dc.setColor(Gfx.COLOR_PURPLE, Gfx.COLOR_TRANSPARENT);
			} else {
				dc.setColor(Gfx.COLOR_DK_BLUE, Gfx.COLOR_TRANSPARENT);
			}	
			dc.fillRectangle(x, y, widthPurpleOrGreen, height);
		}
		
		if (stepWidthBlue > 0){
			if (stepPercentage < 1){
				dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
			} else {
				dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
			}
			dc.fillRectangle(xLocBlue, y, stepWidthBlue, height);
		}
		
		if (moveWidthRed > 0){
			dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
			dc.fillRectangle(xLocRed, y, moveWidthRed, height);
		}
		
		dc.setColor(lineColor, Gfx.COLOR_TRANSPARENT);
		if (widthWhite > 0){
			dc.fillRectangle(xLocWhite, y, widthWhite, height);
		}
		if (xLocSeparator > 0){
			dc.drawLine(xLocSeparator, y, xLocSeparator, y+height);	
		}
    }
    
    // add onSettingsChanged() method also to your View
	function onSettingsChanged() {
		reloadResources(); // here you can load new properties.. you should call it also from onLayout() to load properties for the first time
		showSeconds = secondsEnabled;
		Ui.requestUpdate(); // refresh immediatelly
	}
    
    function onExitSleep(){
    	if (secondsEnabled){
    		showSeconds = true;
    		//Ui.requestUpdate();
    	} else {
    		showSeconds = false;
    	}
    }
    
    function onEnterSleep(){
    	if (secondsEnabled){
    		showSeconds = false;
    		Ui.requestUpdate();
    	} else {
    		showSeconds = false;
    	}
    }
    
}