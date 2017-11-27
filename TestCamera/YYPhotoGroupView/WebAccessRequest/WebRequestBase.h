//
//  WebRequestBase.h
//  WebAccessRequest
//
//  Created by Nep on 10/16/12.
//
//

#ifndef PwC_Contacts_for_iPhone_WebRequestBase_h
#define PwC_Contacts_for_iPhone_WebRequestBase_h

typedef enum {
    WebAccessResultWaiting,
    WebAccessResultNoConnection,
    WebAccessResultTimeOut,
    WebAccessResultFailed,
    WebAccessResultCancelled,
    WebAccessResultDone
} WebAccessResult;

#endif
