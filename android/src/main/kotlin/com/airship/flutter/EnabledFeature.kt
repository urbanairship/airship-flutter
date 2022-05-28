package com.airship.flutter

/// The order of enums constant
/// is critically important to take full advantage of ordinality.
enum class EnabledFeature {
    //FEATURE_NONE
    NONE,
    //FEATURE_IN_APP_AUTOMATION
    IN_APP_AUTOMATION,
    //FEATURE_MESSAGE_CENTER
    MESSAGE_CENTER,
    //FEATURE_PUSH
    PUSH,
    //FEATURE_CHAT
    CHAT,
    //FEATURE_ANALYTICS
    ANALYTICS,
    //FEATURE_TAGS_AND_ATTRIBUTES
    TAGS_AND_ATTRIBUTES,
    //FEATURE_CONTACTS
    CONTACTS,
    //FEATURE_LOCATION
    LOCATION,
    //FEATURE_ALL
    ALL;
    fun featureSupportLevel():Int{
        if(ordinal == 0){
            return  ordinal;
        }
        return  1.shl(ordinal-1)
    }
}