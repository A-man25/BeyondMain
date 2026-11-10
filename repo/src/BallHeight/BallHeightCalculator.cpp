/******************************************************************************
 * BEYONDMAIN | C++
 ******************************************************************************
 * Author      : Aman Rajesh Choudhari
 * File        : BallHeightCalculator.cpp
 * Description : Class for calculating the height of a ball dropped 
				 from a certain height after a certain time
 *
 * Copyright (c) 2026 Aman Rajesh Choudhari.
 ******************************************************************************/


#include "BallHeightCalculator.h"

BallHeightCalculator:: BallHeightCalculator(double height, double time) : m_height(height), m_maxTime(time)
{
	if (!checkBallInputs())
		throw std::invalid_argument("Invalid height");
}

void BallHeightCalculator::calculateBallHeight() const
{
	//distance fallen = gravity_constant * x_seconds2 / 2

	for (int i = 0; i <= m_maxTime; i++)
	{
		double distance = m_height - (GRAVITY * ((double)(i * i) / 2));

		if (distance < 0.0)
			break;

		printBallHeight(i, distance);
	}
	
}

bool BallHeightCalculator::checkBallInputs() const
{
	bool res = false;

	if (m_height < 0.0 && (m_maxTime < 0 || m_maxTime > 10))
		res = false;

	res = true;

	return true;
}

void BallHeightCalculator::printBallHeight(int time, double distance) const
{
	std::cout << "At " << time << " seconds, the ball is at height : " << distance << " meters" << std::endl;
}