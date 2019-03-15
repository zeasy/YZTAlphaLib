//  ALPHACache is a modified version of TMCache
//  Modifications by Garrett Moon
//  Copyright © 2015 Pinterest. All rights reserved.

#ifndef ALPHACache_nullability_h
#define ALPHACache_nullability_h

#if !__has_feature(nullability)
#define NS_ASSUME_NONNULL_BEGIN
#define NS_ASSUME_NONNULL_END
#define nullable
#define nonnull
#define null_unspecified
#define null_resettable
#define __nullable
#define __nonnull
#define __null_unspecified
#endif

#endif
