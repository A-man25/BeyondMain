/******************************************************************************
 * BEYONDMAIN | C++
 ******************************************************************************
 * Author      : Aman Rajesh Choudhari
 * File        : WordGuessSimulator.cpp
 * Description : Class for Word Guess Simulation
 *
 * Copyright (c) 2026 Aman Rajesh Choudhari.
 ******************************************************************************/

#include "WordGuessSimulator.h"

WordGuessSimulationData::WordGuessSimulationData():m_lifeCount(3)
{
	initWord();
	initDisplayContainer();
}

void WordGuessSimulationData::play()
{
	initDisplay();

	bool gameFlag = true;

	WordOutput processedWords;

	while (gameFlag)
	{
		m_UIObj.clearConsole();
		m_UIObj.displayCurrentState(m_DisplayContainer);
		m_UIObj.askSelection();
		m_Input =  m_InputObj.getUserSelection();

		if (m_Input == 5)
			break;

		if (m_lifeCount == 0)
			break;
		
		if (isInList(m_Input, processedWords))
			continue;

		PosList tempIndexList;
		bool found = process(tempIndexList);
		if (found)
		{
			for (const auto index : tempIndexList)
			{
				m_DisplayContainer[index] = m_Input;
			}

			processedWords.push_back(tempIndexList[0]);
		}
		else
		{
			m_lifeCount--;
			m_UIObj.displayLives(m_lifeCount);
		}


		if (isInList('_', m_DisplayContainer))
			continue;

		gameFlag = false;
	}

}

bool WordGuessSimulationData::process(PosList& oIndexList)
{
	bool found = false;
	for (int i = 0; i<m_Word.size(); i++)
	{
		char val = m_Word[i];

		if (val == m_Input)
		{
			oIndexList.push_back(i);
			found = true;
		}
	}

	return found;
	
}

bool WordGuessSimulationData::isInList(char word, WordOutput line)
{
	for (const auto val : line)
	{
		if (val == word)
			return true;
	}

	return false;
	
}

void WordGuessSimulationData::initWord()
{
	m_Word = WORD_GUESS_TEMP;
	
}

void WordGuessSimulationData::initDisplayContainer()
{
	for (int i = 0; i < m_Word.size(); i++)
	{
		m_DisplayContainer.push_back('_');
	}
}

void WordGuessSimulationData::initDisplay()
{
	m_UIObj.printHeader();
	m_UIObj.printRules();
}