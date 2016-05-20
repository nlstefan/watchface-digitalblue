using Toybox.Application as App;

class DigitalBlueApp extends App.AppBase {
	var view = null;
    //! onStart() is called on application start up
    function onStart() {
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    }

    //! Return the initial view of your application here
    function getInitialView() {
    	view  = new DigitalBlueView();
        return [ view ];
    }
    
    function onSettingsChanged()
    {
        if (view != null) {
        	view.onSettingsChanged(); // pass the call of onSettingsChanged directly to the View
        }
    }

}