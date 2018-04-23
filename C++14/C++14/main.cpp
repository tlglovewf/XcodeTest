//
//  main.cpp
//  C++14
//
//  Created by TuLigen on 2018/3/16.
//  Copyright © 2018年 TuLigen. All rights reserved.
//

#include <iostream>
#include <set>
#include <map>
using namespace std;

template<typename ...Types>
class variant
{
public:
    using types = std::tuple<Types...>;
    
    using first_data  = typename std::tuple_element<0, types>::type;
    using second_data = typename std::tuple_element<1, types>::type;
    
     std::size_t type_index;
    
    static const std::size_t data_size  = sizeof...(Types);
    //static const std::size_t data_align = alignof(Types)...;
    types  t;
public:
    variant():type_index(sizeof...(Types) - 1)
    {}
    
    variant(types T):t(T)
    {
        
    }
    template<typename T>
    bool is()
    {
        return true;
    }
};

class Test
{
public:
    Test(int _a,int _b):a(_a),b(_b){}
    
    void display()const{ cout << a << " " << b << endl ;}
    
    float getCenter()const { return (a + b)/2.0;}
public:
    int a;
    int b;
};
template <typename ...Ps>
class TypeList{};

typedef bool (*cmp)(const Test &t1, const Test &t2);

bool Comp( const Test &t1, const Test &t2)
{
    return  t1.getCenter() < t2.getCenter();
    
}

class AATest
{
public:
    AATest(string str, int x):ss(str),xx(x){}
    
    void display()const
    {
        cout << ss.c_str() << " " << xx << endl;
    }
private:
    string ss;
    int    xx;
};

int main(int argc, const char * argv[]) {

    map<string, AATest> str;
    
    str.emplace(
                std::piecewise_construct,
                std::forward_as_tuple("test"),
                std::forward_as_tuple("one",2));
    
    
    str.begin()->second.display();
    return 0;
}


