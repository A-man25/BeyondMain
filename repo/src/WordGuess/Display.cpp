/******************************************************************************
 * BEYONDMAIN | C++
 ******************************************************************************
 * Author      : Aman Rajesh Choudhari
 * File        : Display.cpp
 * Description : Display implemetaiton for Word Guess
 *
 * Copyright (c) 2026 Aman Rajesh Choudhari.
 ******************************************************************************/

#include "Display.h"


void WordGuessUI::printHeader()
{
	std::cout << "******************************************************************************"       << std::endl;
	std::cout << "* BEYONDMAIN | C++"                                                                   << std::endl;
	std::cout << "******************************************************************************\n\n\n" << std::endl;

	std::cout << "******************************************************************************"       << std::endl;
	std::cout << "* STARTING WORD GUESS"                                                                << std::endl;
	std::cout << "******************************************************************************\n\n\n" << std::endl;

	std::cout << "READY ??????\n\n\n";
}

void WordGuessUI::printRules()
{
	std::cout << "The computer selects a secret English word" << std::endl;
	std::cout << "The player must discover that word by guessing one letter at a time." << std::endl;
	std::cout << "Initially, every letter in the word is hidden." << std::endl;
	std::cout << "Each correct guess reveals all occurrences of that letter.Each incorrect guess consumes one available mistake.\n\n" << std::endl;
}

void WordGuessUI::displayLives(int life)
{
	std::cout << "Lives remaining : " << life <<"\n" << std::endl;
}

void WordGuessUI::displayCurrentState(const WordOutput& out)
{
	std::cout << "\n\n" << std::endl;

	for (const auto word : out)
	{
		std::cout << word << " ";
	}

	std::cout << "\n\n" << std::endl;
}

void WordGuessUI::askSelection()
{
	std::cout << "Enter your choice: " << std::endl;
}

void WordGuessUI::displayEND()
{
	std::cout << "******************************************************************************" << std::endl;
	std::cout << "* BLOODY UNEMPLOYED" << std::endl;
	std::cout << "******************************************************************************\n\n\n" << std::endl;
}

void WordGuessUI::clearConsole()
{
	std::cout << "\033[2J\033[H" << std::flush;
}