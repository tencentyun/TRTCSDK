#include "StdAfx.h"
#include "ConfigMgr.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <cstdlib>
#include <vector>
#include "util/Base.h"

//#define INIDEBUG

//INI文件结点存储结构
class ININode
{
public:
    ININode(std::wstring root, std::wstring key, std::wstring value)
    {
        this->root = root;
        this->key = key;
        this->value = value;
    }
    std::wstring root;
    std::wstring key;
    std::wstring value;
};
//////////////////////////////////////////////////////////////////////////ININode

CConfigMgr::CConfigMgr()
{
    wchar_t szCurrentDirectory[MAX_PATH] = { 0 };
    DWORD dwCurDirPathLen;
    dwCurDirPathLen = GetModuleFileNameW(NULL, szCurrentDirectory, MAX_PATH);
    std::wstring appPath;
    appPath = szCurrentDirectory;
    int pos = appPath.find_last_of(L'\\');
    int size = appPath.size();
    _IncFilePath = appPath.erase(pos, size);
    _IncFilePath += L"\\TrtcConfig.ini";
    InitReadINI();
}

CConfigMgr::~CConfigMgr()
{
    WriteINI();
}

//************************************************************************
// 函数名称:        TrimString
// 访问权限:        public 
// 创建日期:        2017/01/05
// 创 建 人:        
// 函数说明:        去除空格
// 函数参数:     string & str    输入的字符串
// 返 回 值:       std::string &    结果字符串
//************************************************************************
std::string &TrimString(std::string &str)
{
    std::string::size_type pos = 0;
    while (str.npos != (pos = str.find(" ")))
        str = str.replace(pos, pos + 1, "");
    return str;
}

//************************************************************************
// 函数名称:        ReadINI
// 访问权限:        public 
// 创建日期:        2017/01/05
// 创 建 人:        
// 函数说明:        读取INI文件，并将其保存到map结构中
// 返 回 值:       int
//************************************************************************
int CConfigMgr::InitReadINI()
{
    ifstream in_conf_file(_IncFilePath.c_str());
    if (!in_conf_file) return 0;
    std::string str_line = "";
    std::string str_root = "";
    std::vector<ININode> vec_ini;
    while (getline(in_conf_file, str_line))
    {
        std::string::size_type left_pos = 0;
        std::string::size_type right_pos = 0;
        std::string::size_type equal_div_pos = 0;
        std::string str_key = "";
        std::string str_value = "";
        if ((str_line.npos != (left_pos = str_line.find("["))) && (str_line.npos != (right_pos = str_line.find("]"))))
        {
            //cout << str_line.substr(left_pos+1, right_pos-1) << endl;
            str_root = str_line.substr(left_pos + 1, right_pos - 1);
        }

        if (str_line.npos != (equal_div_pos = str_line.find("=")))
        {
            str_key = str_line.substr(0, equal_div_pos);
            str_value = str_line.substr(equal_div_pos + 1, str_line.size() - 1);
            //str_key = TrimString(str_key);
            //str_value = TrimString(str_value);
            //cout << str_key << "=" << str_value << endl;
        }

        if ((!str_root.empty()) && (!str_key.empty()) && (!str_value.empty()))
        {
            ININode ini_node(UTF82Wide(str_root), UTF82Wide(str_key), UTF82Wide(str_value));
            vec_ini.push_back(ini_node);
            //cout << vec_ini.size() << endl;
        }
    }
    in_conf_file.close();
    in_conf_file.clear();

    //vector convert to map
    std::map<std::wstring, std::wstring> map_tmp;
    for (vector<ININode>::iterator itr = vec_ini.begin(); itr != vec_ini.end(); ++itr)
    {
        map_tmp.insert(std::pair<std::wstring, std::wstring>(itr->root, L""));
    }    //提取出根节点
    for (std::map<std::wstring, std::wstring>::iterator itr = map_tmp.begin(); itr != map_tmp.end(); ++itr)
    {
#ifdef INIDEBUG
        cout << "根节点： " << itr->first << endl;
#endif    //INIDEBUG
        SubNode sn;
        for (std::vector<ININode>::iterator sub_itr = vec_ini.begin(); sub_itr != vec_ini.end(); ++sub_itr)
        {
            if (sub_itr->root == itr->first)
            {
#ifdef INIDEBUG
                cout << "键值对： " << sub_itr->key << "=" << sub_itr->value << endl;
#endif    //INIDEBUG
                sn.InsertElement(sub_itr->key, sub_itr->value);
            }
        }
        map_ini.insert(std::pair<std::wstring, SubNode>(itr->first, sn));
    }
    return 1;
}

//************************************************************************
// 函数名称:        GetValue
// 访问权限:        public 
// 创建日期:        2017/01/05
// 创 建 人:        
// 函数说明:        根据给出的根结点和键值查找配置项的值
// 函数参数:     string root        配置项的根结点
// 函数参数:     string key        配置项的键
// 返 回 值:       std::string        配置项的值
//************************************************************************
bool CConfigMgr::GetValue(std::wstring root, std::wstring key, std::wstring& value)
{
    std::map<std::wstring, SubNode>::iterator itr = map_ini.find(root);
    if (map_ini.end() == itr)
    {
        value = L"";
        return false;
    }

    std::map<std::wstring, std::wstring>::iterator sub_itr = itr->second.sub_node.find(key);
    if (itr->second.sub_node.end() == sub_itr)
    {
        value = L"";
        return false;
    }

    if (sub_itr->second.empty())
    {
        value = L"";
        return false;
    }

    value = sub_itr->second;
    return true;
}

//************************************************************************
// 函数名称:        WriteINI
// 访问权限:        public 
// 创建日期:        2017/01/05
// 创 建 人:        
// 函数说明:    保存XML的信息到文件中
// 函数参数:     string path    INI文件的保存路径
// 返 回 值:       int
//************************************************************************
int CConfigMgr::WriteINI()
{
    //...文件打开，保存信息，关闭文件等操作。
    wofstream out_conf_file(_IncFilePath.c_str());
    if (!out_conf_file)
        return -1;
    //cout << map_ini.size() << endl;
    for (std::map<std::wstring, SubNode>::iterator itr = map_ini.begin(); itr != map_ini.end(); ++itr)
    {
        //cout << itr->first << endl;
        out_conf_file << "[" << Wide2UTF8(itr->first).c_str() << "]" << endl;
        for (std::map<std::wstring, std::wstring>::iterator sub_itr = itr->second.sub_node.begin(); sub_itr != itr->second.sub_node.end(); ++sub_itr)
        {
            //cout << sub_itr->first << "=" << sub_itr->second << endl;
            out_conf_file << Wide2UTF8(sub_itr->first).c_str() << "=" << Wide2UTF8(sub_itr->second).c_str() << endl;
        }
    }
    out_conf_file.close();
    out_conf_file.clear();
    return 1;
}


//************************************************************************
// 函数名称:        SetValue
// 访问权限:        public 
// 创建日期:        2017/01/05
// 创 建 人:        
// 函数说明:        设置配置项的值
// 函数参数:     string root        配置项的根节点
// 函数参数:     string key        配置项的键
// 函数参数:     string value    配置项的值
// 返 回 值:       std::vector<ININode>::size_type    
//************************************************************************
bool CConfigMgr::SetValue(std::wstring root, std::wstring key, std::wstring value)
{
    std::map<std::wstring, SubNode>::iterator itr = map_ini.find(root);    //查找
    if (map_ini.end() != itr)
    {
        itr->second.sub_node[key] = value;
    }    //根节点已经存在了，更新值
    else
    {
        SubNode sn;
        sn.InsertElement(key, value);
        map_ini.insert(std::pair<std::wstring, SubNode>(root, sn));
    }    //根节点不存在，添加值

    return true;
}

//************************************************************************
// 函数名称:        Travel
// 访问权限:        public 
// 创建日期:        2017/01/05
// 创 建 人:        
// 函数说明:        遍历打印INI文件
// 返 回 值:       void
//************************************************************************
void CConfigMgr::Travel()
{
    for (std::map<std::wstring, SubNode>::iterator itr = this->map_ini.begin(); itr != this->map_ini.end(); ++itr)
    {
        //root
        cout << L"[" << itr->first.c_str() << L"]" << endl;
        for (std::map<std::wstring, std::wstring>::iterator itr1 = itr->second.sub_node.begin(); itr1 != itr->second.sub_node.end();
            ++itr1)
        {
            cout << L"    " << itr1->first.c_str() << L" = " << itr1->second.c_str() << endl;
        }
    }
}