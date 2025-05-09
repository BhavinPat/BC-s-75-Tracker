//
//  Extension.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 1/22/25.
//
import Foundation
import Firebase
import FirebaseStorage
import FirebaseAuth
/*
extension AuthErrorCode.Type{
    /// A user displayable description of the error
    var description: String {
        switch self {
            case .accountExistsWithDifferentCredential:
                return "\(self)"
            case .invalidCustomToken:
                return "\(self)"
            case .customTokenMismatch:
                return "\(self)"
            case .invalidCredential:
                return "Invalid credentials try logging in again"
            case .userDisabled:
                return "Your account has been disabled please contact support"
            case .operationNotAllowed:
                return "\(self)"
            case .emailAlreadyInUse:
                return "Email is in use please try logging in"
            case .invalidEmail:
                return "Enter valid email"
            case .wrongPassword:
                return "Incorrect password"
            case .tooManyRequests:
                return "Too many request please try again later"
            case .userNotFound:
                return "User not found please try creating an account"
            case .requiresRecentLogin:
                return "\(self)"
            case .providerAlreadyLinked:
                return "\(self)"
            case .noSuchProvider:
                return "\(self)"
            case .invalidUserToken:
                return "\(self)"
            case .networkError:
                return "No internet connection"
            case .userTokenExpired:
                return "\(self)"
            case .invalidAPIKey:
                return "\(self)"
            case .userMismatch:
                return "\(self)"
            case .credentialAlreadyInUse:
                return "\(self)"
            case .weakPassword:
                return "password is too weak"
            case .appNotAuthorized:
                return "\(self)"
            case .expiredActionCode:
                return "\(self)"
            case .invalidActionCode:
                return "\(self)"
            case .invalidMessagePayload:
                return "\(self)"
            case .invalidSender:
                return "\(self)"
            case .invalidRecipientEmail:
                return "\(self)"
            case .missingEmail:
                return "No email provided"
            case .missingIosBundleID:
                return "\(self)"
            case .missingAndroidPackageName:
                return "\(self)"
            case .unauthorizedDomain:
                return "\(self)"
            case .invalidContinueURI:
                return "\(self)"
            case .missingContinueURI:
                return "\(self)"
            case .missingPhoneNumber:
                return "\(self)"
            case .invalidPhoneNumber:
                return "\(self)"
            case .missingVerificationCode:
                return "\(self)"
            case .invalidVerificationCode:
                return "\(self)"
            case .missingVerificationID:
                return "\(self)"
            case .invalidVerificationID:
                return "\(self)"
            case .missingAppCredential:
                return "\(self)"
            case .invalidAppCredential:
                return "\(self)"
            case .sessionExpired:
                return "\(self)"
            case .quotaExceeded:
                return "\(self)"
            case .missingAppToken:
                return "\(self)"
            case .notificationNotForwarded:
                return "\(self)"
            case .appNotVerified:
                return "\(self)"
            case .captchaCheckFailed:
                return "\(self)"
            case .webContextAlreadyPresented:
                return "\(self)"
            case .webContextCancelled:
                return "\(self)"
            case .appVerificationUserInteractionFailure:
                return "\(self)"
            case .invalidClientID:
                return "\(self)"
            case .webNetworkRequestFailed:
                return "\(self)"
            case .webInternalError:
                return "\(self)"
            case .webSignInUserInteractionFailure:
                return "\(self)"
            case .localPlayerNotAuthenticated:
                return "\(self)"
            case .nullUser:
                return "\(self)"
            case .dynamicLinkNotActivated:
                return "\(self)"
            case .invalidProviderID:
                return "\(self)"
            case .tenantIDMismatch:
                return "\(self)"
            case .unsupportedTenantOperation:
                return "\(self)"
            case .invalidDynamicLinkDomain:
                return "\(self)"
            case .rejectedCredential:
                return "\(self)"
            case .gameKitNotLinked:
                return "\(self)"
            case .secondFactorRequired:
                return "\(self)"
            case .missingMultiFactorSession:
                return "\(self)"
            case .missingMultiFactorInfo:
                return "\(self)"
            case .invalidMultiFactorSession:
                return "\(self)"
            case .multiFactorInfoNotFound:
                return "\(self)"
            case .adminRestrictedOperation:
                return "\(self)"
            case .unverifiedEmail:
                return "\(self)"
            case .secondFactorAlreadyEnrolled:
                return "\(self)"
            case .maximumSecondFactorCountExceeded:
                return "\(self)"
            case .unsupportedFirstFactor:
                return "\(self)"
            case .emailChangeNeedsVerification:
                return "\(self)"
            case .missingOrInvalidNonce:
                return "\(self)"
            case .missingClientIdentifier:
                return "\(self)"
            case .keychainError:
                return "\(self)"
            case .internalError:
                return "Internal error please try again later"
            case .malformedJWT:
                return "\(self)"
            case .blockingCloudFunctionError:
                return "\(self)"
            @unknown default:
                return "Error"
        }
    }
}

extension StorageErrorCode {
    /// A user displayable description of the error
    var description: String {
        switch self {
            case .bucketNotFound:
                return "\(self)"
            case .unknown:
                return "Unknown Error"
            case .objectNotFound:
                return "\(self)"
            case .projectNotFound:
                return "\(self)"
            case .quotaExceeded:
                return "\(self)"
            case .unauthenticated:
                return "\(self)"
            case .unauthorized:
                return "Your account is unauthorized"
            case .retryLimitExceeded:
                return "Retry Failed"
            case .nonMatchingChecksum:
                return "\(self)"
            case .downloadSizeExceeded:
                return "Download file exceeded max allowed size"
            case .cancelled:
                return "Request Cancelled"
            case .invalidArgument:
                return "\(self)"
        }
    }
}
*/
extension String {
    
    ///
    func isEmail() -> Bool {
        let __firstpart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
        let __serverpart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
        let __emailRegex = __firstpart + "@" + __serverpart + "[A-Za-z]{2,8}"
        let __emailPredicate = NSPredicate(format: "SELF MATCHES %@", __emailRegex)
        return __emailPredicate.evaluate(with: self)
    }
}
