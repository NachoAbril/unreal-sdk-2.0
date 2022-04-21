// Copyright (c) devtodev. All rights reserved.

#include "MacAnalytics.h"

#include "DTDAnalytics/DTDAnalytics-Swift.h"

#include "Misc/DateTime.h"

#include "MacConverter.h"
#include "Constants/SDKConstants.h"
#include "Logging/DTDLogs.h"

@interface OSXIdentifiersListener : NSObject<DTDIdentifiersListener>
{
    const FDTDLongListenerDelegate* onResult;    
}

-(id)initWithDelegate:(const FDTDLongListenerDelegate*)delegate;
@end

@implementation OSXIdentifiersListener
-(id)initWithDelegate:(const FDTDLongListenerDelegate*)delegate {
	onResult = delegate;
    return self;
}

- (void)didReceiveDevtodevIdWith:(int64_t)devtodevId {
	int64 u_devtodevId = static_cast<int64>(devtodevId);
	onResult->ExecuteIfBound(u_devtodevId);
}
@end

MacAnalytics::MacAnalytics()
{
#if WITH_EDITOR
	[::DTDEngineWrapper enableEditorMode];
#endif
    [::DTDEngineWrapper setSDKVersionWithVersion:MacConverter::Convert(SDKConstants::Version)];
	[::DTDEngineWrapper setEngineLoggerMessageClosure:^(DTDLogLevel logLevel, NSString* message) {
		const auto u_logLevel = MacConverter::Convert(logLevel);
		const auto u_message = MacConverter::Convert(message);
#if !UE_BUILD_SHIPPING
		const auto u_now = FDateTime::Now().ToString(TEXT("%Y/%m/%d %H:%M:%S:%s"));
#else 
		const auto u_now = FDateTime::Now().ToString(TEXT("%Y/%m/%d %H:%M:%S"));
#endif
		TArray<FStringFormatArg> formattingArgs; 
		formattingArgs.Add(FStringFormatArg(u_now));
		formattingArgs.Add(FStringFormatArg(SDKConstants::Version));
		formattingArgs.Add(FStringFormatArg(u_message));
		const auto formattedMessage = FString::Format(TEXT("{0} [DevToDev {1}] {2}"), formattingArgs);
		switch (u_logLevel)
		{
		case EDTDLogLevel::Error:
			UE_LOG(LogTemp, Error, TEXT("%s"), *formattedMessage);
			break;
		case EDTDLogLevel::Warning:
			UE_LOG(LogTemp, Warning, TEXT("%s"), *formattedMessage);
			break;
		case EDTDLogLevel::Info:
		case EDTDLogLevel::Debug:
			UE_LOG(LogTemp, Display, TEXT("%s"), *formattedMessage);
			break;
		default:
			break;
		}

		if (logsListener != nullptr)
		{
        	logsListener->ExecuteIfBound(u_logLevel, formattedMessage);
		}
    }];
}

MacAnalytics::~MacAnalytics()
{
	if (logsListener != nullptr)
	{
		delete logsListener;
	}
}

void MacAnalytics::SetTestProxyUrl(const FString& url)
{
	[::DTDAnalytics setTestProxyUrlWithUrl:MacConverter::Convert(url)];
}

void MacAnalytics::SetTestCustomUrl(const FString& url)
{
	[::DTDAnalytics setTestCustomUrlWithUrl:MacConverter::Convert(url)];
}

void MacAnalytics::TestLogs()
{
	[::DTDAnalytics testLogs];
}

void MacAnalytics::TestString(const FString& value)
{
	[::DTDEngineWrapper testStringWithValue:MacConverter::Convert(value)];
}

void MacAnalytics::SetLoggerMessageListener(const FDTDLogsListenerDelegate* listener)
{
	if (logsListener != nullptr)
	{
		delete logsListener;
	}

	logsListener = listener;
}

void MacAnalytics::SetIdentifiersListener(const FDTDLongListenerDelegate* listener)
{
	[::DTDAnalytics setIdentifiersListenerWithListener:[[OSXIdentifiersListener alloc] initWithDelegate:listener]];
}

void MacAnalytics::GetDeviceId(const FDTDGetterStringDelegate* onResult)
{
	[::DTDAnalytics deviceIdHandler:^(NSString* value) {
        onResult->ExecuteIfBound(MacConverter::Convert(value));
		delete onResult;
    }];
}

void MacAnalytics::GetSdkVersion(const FDTDGetterStringDelegate* onResult)
{
	[::DTDAnalytics sdkVersionHandler:^(NSString* value) {
        onResult->ExecuteIfBound(MacConverter::Convert(value));
		delete onResult;
    }];
}

void MacAnalytics::GetApplicationVersion(const FDTDGetterStringDelegate* onResult)
{
	delete onResult;

	// Not supported.
	DTDLogs::MethodAvailableOnlyForWindowsPlatformWarning("GetApplicationVersion");
}

void MacAnalytics::SetApplicationVersion(const FString& value)
{
	// Not supported.
	DTDLogs::MethodAvailableOnlyForWindowsPlatformWarning("SetApplicationVersion");
}

void MacAnalytics::GetTrackingAvailability(const FDTDGetterBoolDelegate* onResult)
{
	[::DTDAnalytics trackingAvailabilityHandler:^(BOOL value) {
        onResult->ExecuteIfBound(MacConverter::ConvertToCpp(value));
		delete onResult;
    }];
}

void MacAnalytics::GetUserId(const FDTDGetterStringDelegate* onResult)
{
	[::DTDAnalytics userIdHandler:^(NSString* value) {
        onResult->ExecuteIfBound(MacConverter::Convert(value));
		delete onResult;
    }];
}

void MacAnalytics::GetCurrentLevel(const FDTDGetterIntDelegate* onResult)
{
	[::DTDAnalytics currentLevelHandler:^(NSInteger value) {
        onResult->ExecuteIfBound(MacConverter::ConvertToInt32(value));
		delete onResult;
    }];
}

void MacAnalytics::Initialize(const FString& appKey)
{
	[::DTDAnalytics applicationKey:MacConverter::Convert(appKey)];
}

void MacAnalytics::InitializeWithConfig(const FString& appKey, const FDTDAnalyticsConfiguration& config)
{
	const auto oco_config = MacConverter::Convert(config);
	const auto ocs_appKey = MacConverter::Convert(appKey);
	[::DTDAnalytics applicationKey:ocs_appKey configuration:oco_config];
	[oco_config release];
}

void MacAnalytics::Deinitialize()
{
	[::DTDEngineWrapper destroySDK];
	// Reset custom parameters because they are destroyed too.
#if WITH_EDITOR
	[::DTDEngineWrapper enableEditorMode];
#endif
    [::DTDEngineWrapper setSDKVersionWithVersion:MacConverter::Convert(SDKConstants::Version)];
}

void MacAnalytics::StartActivity()
{
	// Not supported.
	DTDLogs::MethodAvailableOnlyForWindowsPlatformWarning("StartActivity");
}

void MacAnalytics::StopActivity()
{
	// Not supported.
	DTDLogs::MethodAvailableOnlyForWindowsPlatformWarning("StopActivity");
}

void MacAnalytics::SetUserId(const FString& userId)
{
	[::DTDAnalytics userId:MacConverter::Convert(userId)];
}

void MacAnalytics::ReplaceUserId(const FString& fromUserId, const FString& toUserId)
{
	[::DTDAnalytics replaceFromUserId:MacConverter::Convert(fromUserId) toUserId:MacConverter::Convert(toUserId)];
}

void MacAnalytics::CustomEvent(const FString& eventName)
{
	[::DTDAnalytics customEvent:MacConverter::Convert(eventName)];
}

void MacAnalytics::CustomEventWithParams(const FString& eventName, const FDTDCustomEventParams& params)
{
	const auto ocs_eventName = MacConverter::Convert(eventName);
	const auto oco_params = MacConverter::Convert(params);
	[::DTDAnalytics customEvent:ocs_eventName withParameters:oco_params];
	[oco_params release];
}

void MacAnalytics::SetCurrentLevel(int32 level)
{
	[::DTDAnalytics currentLevel:MacConverter::Convert(level)];
}

void MacAnalytics::SetTrackingAvailability(bool value)
{
	[::DTDAnalytics trackingAvailability:MacConverter::ConvertToObjC(value)];
}

void MacAnalytics::CurrencyAccrual(const FString& currencyName, int32 currencyAmount, const FString& source, EDTDAccrualType accrualType)
{
	[::DTDAnalytics currencyName:MacConverter::Convert(currencyName) currencyAmount:MacConverter::Convert(currencyAmount) source:MacConverter::Convert(source) accrualType:MacConverter::Convert(accrualType)];
}

void MacAnalytics::VirtualCurrencyPayment(const FString& purchaseId, const FString& purchaseType, int32 purchaseAmount, int32 purchasePrice, const FString& purchaseCurrency)
{
	[::DTDAnalytics virtualCurrencyPaymentWithPurchaseId:MacConverter::Convert(purchaseId) purchaseType:MacConverter::Convert(purchaseType) purchaseAmount:MacConverter::Convert(purchaseAmount) purchasePrice:MacConverter::Convert(purchasePrice) purchaseCurrency:MacConverter::Convert(purchaseCurrency)];
}

void MacAnalytics::VirtualCurrencyPaymentWithResources(const FString& purchaseId, const FString& purchaseType, int32 purchaseAmount, const TMap<FString, int32>& resources)
{
	const auto ocs_purchaseId = MacConverter::Convert(purchaseId);
	const auto ocs_purchaseType = MacConverter::Convert(purchaseType);
	const auto ocp_purchaseAmount = MacConverter::Convert(purchaseAmount);
	const auto oco_resources = MacConverter::Convert(resources);
	[::DTDAnalytics virtualCurrencyPaymentWithPurchaseId:ocs_purchaseId purchaseType:ocs_purchaseType purchaseAmount:ocp_purchaseAmount resources:oco_resources];
	[oco_resources release];
}

void MacAnalytics::LevelUp(int32 level)
{
	[::DTDAnalytics levelUp:MacConverter::Convert(level)];
}

void MacAnalytics::LevelUpWithBalance(int32 level, const TMap<FString, int64>& balance)
{
	const auto ocp_level = MacConverter::Convert(level);
	const auto oco_balance = MacConverter::Convert(balance);
	[::DTDAnalytics levelUp:ocp_level withBalances:oco_balance];
	[oco_balance release];
}

void MacAnalytics::CurrentBalance(const TMap<FString, int64>& balance)
{
	const auto oco_balance = MacConverter::Convert(balance);
	[::DTDAnalytics currentBalanceWithBalance:oco_balance];
	[oco_balance release];
}

void MacAnalytics::Referrer(const TMap<EDTDReferralProperty, FString>& utmData)
{
	const auto oco_utmData = MacConverter::Convert(utmData);
	[::DTDAnalytics referrer:oco_utmData];
	[oco_utmData release];
}

void MacAnalytics::Tutorial(int32 step)
{
	[::DTDAnalytics tutorialStep:MacConverter::Convert(step)];
}

void MacAnalytics::StartProgressionEvent(const FString& eventName)
{
	[::DTDAnalytics startProgressionEvent:MacConverter::Convert(eventName)];
}

void MacAnalytics::StartProgressionEventWithParams(const FString& eventName, const FDTDStartProgressionEventParams& params)
{
	const auto ocs_eventName = MacConverter::Convert(eventName);
	const auto oco_params = MacConverter::Convert(params);
	[::DTDAnalytics startProgressionEvent:ocs_eventName withParameters:oco_params];
	[oco_params release];
}

void MacAnalytics::FinishProgressionEvent(const FString& eventName)
{
	[::DTDAnalytics finishProgressionEvent:MacConverter::Convert(eventName)];
}

void MacAnalytics::FinishProgressionEventWithParams(const FString& eventName, const FDTDFinishProgressionEventParams& params)
{
	const auto ocs_eventName = MacConverter::Convert(eventName);
	const auto oco_params = MacConverter::Convert(params);
	[::DTDAnalytics finishProgressionEvent:ocs_eventName withParameters:oco_params];
	[oco_params release];
}

void MacAnalytics::RealCurrencyPayment(const FString& orderId, float price, const FString& productId, const FString& currencyCode)
{
	[::DTDAnalytics realCurrencyPaymentWithOrderId:MacConverter::Convert(orderId) price:(double)price productId:MacConverter::Convert(productId) currencyCode:MacConverter::Convert(currencyCode)];
}

void MacAnalytics::SocialNetworkConnect(EDTDSocialNetwork socialNetwork)
{
	const auto oco_socialNetwork = MacConverter::Convert(socialNetwork);
	[::DTDAnalytics socialNetworkConnect:oco_socialNetwork];
	[oco_socialNetwork release];
}

void MacAnalytics::SocialNetworkConnectCustom(const FString& socialNetwork)
{
	[::DTDAnalytics socialNetworkConnect:MacConverter::ConvertToSocialNetwork(socialNetwork)];
}

void MacAnalytics::SocialNetworkPost(EDTDSocialNetwork socialNetwork, const FString& reason)
{
	const auto oco_socialNetwork = MacConverter::Convert(socialNetwork);
	const auto ocs_reason = MacConverter::Convert(reason);
	[::DTDAnalytics socialNetworkPost:oco_socialNetwork withReason:ocs_reason];
	[oco_socialNetwork release];
}

void MacAnalytics::SocialNetworkPostCustom(const FString& socialNetwork, const FString& reason)
{
	[::DTDAnalytics socialNetworkPost:MacConverter::ConvertToSocialNetwork(socialNetwork) withReason:MacConverter::Convert(reason)];
}

void MacAnalytics::AdImpression(const FString& socialNetwork, float revenue, const FString& placement, const FString& unit)
{
	const auto ocs_socialNetwork = MacConverter::Convert(socialNetwork);
	const auto ocp_revenue = static_cast<double>(revenue);
	const auto ocs_placement = MacConverter::Convert(placement);
	const auto ocs_unit = MacConverter::Convert(unit);
	[::DTDAnalytics adImpressionWithNetwork:ocs_socialNetwork revenue:ocp_revenue placement:ocs_placement unit:ocs_unit];
}

void MacAnalytics::SendBufferedEvents()
{
	[::DTDAnalytics sendBufferedEvents];
}

void MacAnalytics::SetLogLevel(EDTDLogLevel logLevel)
{
	[::DTDAnalytics setLogLevel:MacConverter::Convert(logLevel)];
}

void MacAnalytics::GetName(const FDTDGetterStringDelegate* onResult)
{
	[::DTDUserCard getNameHandler:^(NSString* value) {
        onResult->ExecuteIfBound(MacConverter::Convert(value));
		delete onResult;
    }];
}

void MacAnalytics::GetEmail(const FDTDGetterStringDelegate* onResult)
{
	[::DTDUserCard getEmailHandler:^(NSString* value) {
        onResult->ExecuteIfBound(MacConverter::Convert(value));
		delete onResult;
    }];
}

void MacAnalytics::GetPhone(const FDTDGetterStringDelegate* onResult)
{
	[::DTDUserCard getPhoneHandler:^(NSString* value) {
        onResult->ExecuteIfBound(MacConverter::Convert(value));
		delete onResult;
    }];
}

void MacAnalytics::GetPhoto(const FDTDGetterStringDelegate* onResult)
{
	[::DTDUserCard getPhotoHandler:^(NSString* value) {
        onResult->ExecuteIfBound(MacConverter::Convert(value));
		delete onResult;
    }];
}

void MacAnalytics::GetGender(const FDTDGetterGenderDelegate* onResult)
{
	[::DTDUserCard getGenderHandler:^(Gender value) {
        onResult->ExecuteIfBound(MacConverter::Convert(value));
		delete onResult;
    }];
}

void MacAnalytics::GetAge(const FDTDGetterLongDelegate* onResult)
{
	[::DTDUserCard getAgeHandler:^(NSInteger value) {
        onResult->ExecuteIfBound(MacConverter::ConvertToInt64(value));
		delete onResult;
    }];
}

void MacAnalytics::GetCheater(const FDTDGetterBoolDelegate* onResult)
{
	[::DTDUserCard getCheaterHandler:^(BOOL value) {
        onResult->ExecuteIfBound(MacConverter::ConvertToCpp(value));
		delete onResult;
    }];
}

void MacAnalytics::TryGetString(const FString& key, const FDTDGetterOptionalStringDelegate* onResult)
{
	[::DTDUserCard getValueWithKey:MacConverter::Convert(key) :^(id value) {
        if (value && [value respondsToSelector:@selector(UTF8String)])
        {
			onResult->ExecuteIfBound(true, MacConverter::FromUtf8String([value UTF8String]));
        }
		else
		{
			onResult->ExecuteIfBound(false, "");
		}
        
		delete onResult;
    }];
}

void MacAnalytics::TryGetBool(const FString& key, const FDTDGetterOptionalBoolDelegate* onResult)
{
	[::DTDUserCard getValueWithKey:MacConverter::Convert(key) :^(id value) {
        if (value && [value respondsToSelector:@selector(boolValue)])
        {
			onResult->ExecuteIfBound(true, MacConverter::ConvertToCpp([value boolValue]));
        }
		else
		{
			onResult->ExecuteIfBound(false, false);
		}
        
		delete onResult;
    }];
}

void MacAnalytics::TryGetFloat(const FString& key, const FDTDGetterOptionalFloatDelegate* onResult)
{
	[::DTDUserCard getValueWithKey:MacConverter::Convert(key) :^(id value) {
        if (value && [value respondsToSelector:@selector(doubleValue)])
        {
			onResult->ExecuteIfBound(true, (float)[value doubleValue]);
        }
		else
		{
			onResult->ExecuteIfBound(false, 0);
		}
        
		delete onResult;
    }];
}

void MacAnalytics::TryGetLong(const FString& key, const FDTDGetterOptionalLongDelegate* onResult)
{
	[::DTDUserCard getValueWithKey:MacConverter::Convert(key) :^(id value) {
        if (value && [value respondsToSelector:@selector(longValue)])
        {
			onResult->ExecuteIfBound(true, MacConverter::ConvertToInt64([value longValue]));
        }
		else
		{
			onResult->ExecuteIfBound(false, 0);
		}
        
		delete onResult;
    }];
}

void MacAnalytics::SetName(const FString& name)
{
	[::DTDUserCard setName:MacConverter::Convert(name)];
}

void MacAnalytics::SetEmail(const FString& email)
{
	[::DTDUserCard setEmail:MacConverter::Convert(email)];
}

void MacAnalytics::SetPhone(const FString& phone)
{
	[::DTDUserCard setPhone:MacConverter::Convert(phone)];
}

void MacAnalytics::SetPhoto(const FString& photo)
{
	[::DTDUserCard setPhoto:MacConverter::Convert(photo)];
}

void MacAnalytics::SetGender(EDTDGender gender)
{
	[::DTDUserCard setGender:MacConverter::Convert(gender)];
}

void MacAnalytics::SetAge(int64 age)
{
	[::DTDUserCard setAge:MacConverter::Convert(age)];
}

void MacAnalytics::SetCheater(bool cheater)
{
	[::DTDUserCard setCheater:MacConverter::ConvertToObjC(cheater)];
}

void MacAnalytics::SetString(const FString& key, const FString& value)
{
	[::DTDUserCard setString:MacConverter::Convert(key) value:MacConverter::Convert(value)];
}

void MacAnalytics::SetBool(const FString& key, bool value)
{
	[::DTDUserCard setBool:MacConverter::Convert(key) value:MacConverter::ConvertToObjC(value)];
}

void MacAnalytics::SetInt(const FString& key, int64 value)
{
	[::DTDUserCard setInt:MacConverter::Convert(key) value:MacConverter::Convert(value)];
}

void MacAnalytics::SetFloat(const FString& key, float value)
{
	[::DTDUserCard setDouble:MacConverter::Convert(key) value:(double)value];
}

void MacAnalytics::Unset(const FString& key)
{
	[::DTDUserCard unsetProperty:MacConverter::Convert(key)];
}

void MacAnalytics::UnsetArray(const TArray<FString>& keys)
{
	const auto oco_keys = MacConverter::Convert(keys);
	[::DTDUserCard unset:oco_keys];
	[oco_keys release];
}

void MacAnalytics::IncrementInt(const FString& key, int64 value)
{
	[::DTDUserCard increment:MacConverter::Convert(key) byInt:MacConverter::Convert(value)];
}

void MacAnalytics::IncrementFloat(const FString& key, float value)
{
	[::DTDUserCard increment:MacConverter::Convert(key) byDouble:(double)value];
}

void MacAnalytics::ClearUser()
{
	[::DTDUserCard clearUser];
}
