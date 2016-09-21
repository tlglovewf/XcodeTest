//
//  Ios_lib.m
//  Ios_lib
//
//  Created by TuLigen on 16/6/23.
//  Copyright (c) 2016年 TuLigen. All rights reserved.
//
#include "Ios_lib.h"


const char* TestIOS::getText()const
{
#ifdef __APPLE__
    return "hello world.";
#else
    return "hello man.";
#endif
}