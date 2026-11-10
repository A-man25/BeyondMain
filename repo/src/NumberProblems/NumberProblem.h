/******************************************************************************
 * BEYONDMAIN | C++
 ******************************************************************************
 * Author      : Aman Rajesh Choudhari
 * File        : NumberProblems.cpp
 * Description : Class for simulating number problems
 *
 * Copyright (c) 2026 Aman Rajesh Choudhari.
 ******************************************************************************/

#pragma once

#include <stdafx.h>


class NumberSimulator
{
public:
	NumberSimulator(int num);
	bool isPrime() const;
	int factorial() const;

private:
	bool isPositive() const;
	int m_Num;
};


