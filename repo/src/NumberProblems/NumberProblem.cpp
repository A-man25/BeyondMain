/******************************************************************************
 * BEYONDMAIN | C++
 ******************************************************************************
 * Author      : Aman Rajesh Choudhari
 * File        : NumberProblems.cpp
 * Description : Class for simulating number problems
 *
 * Copyright (c) 2026 Aman Rajesh Choudhari.
 ******************************************************************************/

#include "NumberProblem.h"

NumberSimulator::NumberSimulator(int num) : m_Num(num)
{

}

bool NumberSimulator::isPrime() const
{
    if (m_Num <= 1)
        return false;

    if (m_Num == 2)
        return true;

    for (int i = 2; i <= m_Num / i; ++i)
    {
        if (m_Num % i == 0)
            return false;
    }

    return true;

}

bool NumberSimulator::isPositive() const
{
	if (m_Num < 0)
        throw std::invalid_argument("Factorial is undefined for negative numbers");

	return true;
}

int NumberSimulator::factorial() const
{
    if (!isPositive())
        return -1;

    unsigned long long factorial = 1;

    for (int i = m_Num; i > 1; i--)
    {
        factorial = i * factorial;
    }

    return factorial;

}