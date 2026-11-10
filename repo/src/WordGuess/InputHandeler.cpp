/******************************************************************************
 * BEYONDMAIN | C++
 ******************************************************************************
 * Author      : Aman Rajesh Choudhari
 * File        : Input Handeler.cpp
 * Description : Input Handeler implementation
 *
 * Copyright (c) 2026 Aman Rajesh Choudhari.
 ******************************************************************************/

#include "InputHandeler.h"

char InputHandeler::getUserSelection()
{
	std::cin >> m_UserSelection;
	return m_UserSelection;
}