#include "script_component.hpp"

#ifdef description_XEH_PreInit
	class AiSupport {
		clientInit = "'' call compile preprocessFileLineNumbers 'modules\ai_support\preInitClient.sqf'";
	};
#endif

#ifdef description_XEH_PostInit
	class AiSupport {
		clientInit = "'' call compile preprocessFileLineNumbers 'modules\ai_support\postInitClient.sqf'";
	};
#endif

#ifdef description_external_functions
	#include "cfgFunctions.hpp"
#endif

#ifdef description
    class GVAR(settings) {
        #include "settings.hpp"
    };
#endif

#undef COMPONENT
