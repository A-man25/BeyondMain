/******************************************************************************
 * BEYONDMAIN | C++
 ******************************************************************************
 * Author      : Aman Rajesh Choudhari
 * File        : WordGuessSimulator.cpp
 * Description : Class for Word Guess Simulator
 *
 * Copyright (c) 2026 Aman Rajesh Choudhari.
 ******************************************************************************/

#pragma once
#include <stdafx.h>
#include "Display.h"
#include "InputHandeler.h"
#include "Common.h"

class WordGuessSimulationData
{
public:
	WordGuessSimulationData();
	void play();
private:
	void initWord();
	void initDisplay();
	void initDisplayContainer();
	bool process(PosList& oIndexList);
	bool isInList(char word, WordOutput line);
	std::string m_Word;
	char m_Input;
	WordOutput m_DisplayContainer;
	WordGuessUI m_UIObj;
	InputHandeler m_InputObj;
	int m_lifeCount;
};