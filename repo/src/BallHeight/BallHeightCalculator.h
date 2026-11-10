/******************************************************************************
 * BEYONDMAIN | C++
 ******************************************************************************
 * Author      : Aman Rajesh Choudhari
 * File        : BallHeightCalculator.h
 * Description : Class for calculating the height of a ball 
				 dropped from a certain height after a certain time
 *
 * Copyright (c) 2026 Aman Rajesh Choudhari.
 ******************************************************************************/


#pragma once
#include <stdafx.h>


/******************************************************************************
 * Inputs
******************************************************************************/
inline constexpr double BALLHEIGHT = 100;
inline constexpr unsigned int FALLTIME = 5;
inline constexpr double GRAVITY = 9.8;


/*
* A ball is dropped from a tower with certain height
*/
class BallHeightCalculator
{
public:
	BallHeightCalculator(double height, double time);
	void calculateBallHeight() const;
private:
	void printBallHeight(int time, double distance) const;
	bool checkBallInputs() const;
	double m_height;
	double m_maxTime;
};