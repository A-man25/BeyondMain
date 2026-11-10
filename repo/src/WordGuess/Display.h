/******************************************************************************
 * BEYONDMAIN | C++
 ******************************************************************************
 * Author      : Aman Rajesh Choudhari
 * File        : Display.cpp
 * Description : Display for Word Guess
 *
 * Copyright (c) 2026 Aman Rajesh Choudhari.
 ******************************************************************************/

#pragma once
#include <stdafx.h>
#include "Common.h"

class WordGuessUI
{
public:
	void printHeader();
	void printRules();
	void displayLives(int life);
	void displayCurrentState(const WordOutput& out);
	void askSelection();
	void displayEND();
	void clearConsole();
private:
};