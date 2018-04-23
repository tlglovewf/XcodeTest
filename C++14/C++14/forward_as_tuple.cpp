//
//  forward_as_tuple.cpp
//  C++14
//
//  Created by TuLigen on 2018/4/23.
//  Copyright © 2018年 TuLigen. All rights reserved.
//

#include <stdio.h>
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
    
    
/**
    这是一个空对象，是 piecewise_construct_t 的一个实例，
    专用于重载 pair 的构造函数，使得可以将两个 tuple 参数中的成员按正确的顺序（In place）传递给对应的构造函数，
    即 pair 内部构造 tuple 对象时不是以另一整个 tuple 为参数（拷贝构造），而是将另一个 tuple 内所有元素拆分开来再传递进构造函数（Piecewise）
**/
    str.emplace(
                std::piecewise_construct,
                std::forward_as_tuple("test"),
                std::forward_as_tuple("one",2));
    
    
    str.begin()->second.display();
    return 0;
}
