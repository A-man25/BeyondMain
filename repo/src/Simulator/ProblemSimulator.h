/******************************************************************************
 * BEYONDMAIN | C++
 ******************************************************************************
 * Author      : Aman Rajesh Choudhari
 * File        : ProblemSimulator.h
 * Description : Class for simulating the problems
 *
 * Copyright (c) 2026 Aman Rajesh Choudhari.
 ******************************************************************************/


#pragma once
#include <stdafx.h>
#include "../BallHeight/BallHeightCalculator.h"
#include "../WordGuess/WordGuessSimulator.h"

class ProblemSimulator 
{
public:
	ProblemSimulator() : m_ballHeightCalculator(BallHeightCalculator(BALLHEIGHT, FALLTIME)) {}

	void run() 
	{
		//m_ballHeightCalculator.calculateBallHeight();
		m_wordGuessGameObj.play();
	}
private:
	BallHeightCalculator m_ballHeightCalculator;
	WordGuessSimulationData m_wordGuessGameObj;
};