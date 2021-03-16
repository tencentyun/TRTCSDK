#include <Windows.h>
#include <commdlg.h>
#include <tchar.h>

#include "FileDialog.h"

//选择文件
int DialogGetFileName(HWND hParent,LPCTSTR strFilter,TCHAR *szFile,int nFileSize)  
{  
	//TCHAR szFile[MAX_PATH]; // 保存获取文件名称的缓冲区
	ZeroMemory(szFile,nFileSize);

	OPENFILENAME ofn;      // 公共对话框结构。    
	// 初始化选择文件对话框。   
	ZeroMemory(&ofn, sizeof(OPENFILENAME));
	ofn.lStructSize = sizeof(OPENFILENAME);  
	ofn.hwndOwner = hParent;
	ofn.lpstrFile = szFile;
	ofn.nMaxFile = nFileSize;
	ofn.lpstrFilter = strFilter/*_T("All(*.*)\0*.*\0Text(*.txt)\0*.TXT\0\0")*/;
	ofn.nFilterIndex = 1;  
	ofn.lpstrFileTitle = NULL;  
	ofn.nMaxFileTitle = 0;  
	ofn.lpstrInitialDir = NULL;  
	ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST;  
	//ofn.lpTemplateName =  MAKEINTRESOURCE(ID_TEMP_DIALOG);  
	// 显示打开选择文件对话框。   

	if ( GetOpenFileName(&ofn) )  
	{  
		//显示选择的文件。   
		//OutputDebugString(szFile);
		return 1;
	} 
	return -1;
}
//多选文件
int GetFileNames()
{
	TCHAR szOpenFileNames[80*MAX_PATH];
	ZeroMemory(szOpenFileNames,80*MAX_PATH);

	OPENFILENAME ofn;
	TCHAR szPath[MAX_PATH];
	TCHAR szFileName[80*MAX_PATH];
	TCHAR* p;
	int nLen = 0;
	ZeroMemory( &ofn, sizeof(ofn) );
	ofn.Flags = OFN_EXPLORER | OFN_ALLOWMULTISELECT;
	ofn.lStructSize = sizeof(ofn);
	ofn.lpstrFile = szOpenFileNames;
	ofn.nMaxFile = sizeof(szOpenFileNames);
	ofn.lpstrFilter = TEXT("All Files(*.*)/0*.*/0");

	if( GetOpenFileName( &ofn ) )
	{  
		//把第一个文件名前的复制到szPath,即:
		//如果只选了一个文件,就复制到最后一个'/'
		//如果选了多个文件,就复制到第一个NULL字符
		lstrcpyn(szPath, szOpenFileNames, ofn.nFileOffset );
		//当只选了一个文件时,下面这个NULL字符是必需的.
		//这里不区别对待选了一个和多个文件的情况
		szPath[ ofn.nFileOffset ] = '/0';
		nLen = lstrlen(szPath);
  
		if( szPath[nLen-1] != '//' )   //如果选了多个文件,则必须加上'//'
		{
			lstrcat(szPath, TEXT("//"));
		}
  
		p = szOpenFileNames + ofn.nFileOffset; //把指针移到第一个文件
  
		ZeroMemory(szFileName, sizeof(szFileName));
		while( *p )
		{   
			lstrcat(szFileName, szPath);  //给文件名加上路径  
			lstrcat(szFileName, p);    //加上文件名  
			lstrcat(szFileName, TEXT("/n")); //换行   
			p += lstrlen(p) +1;     //移至下一个文件
		}
		MessageBox(NULL, szFileName, TEXT("MultiSelect"), MB_OK);
		return 1;
	}
	return -1;
}
#include <ShlObj.h>

//选择文件夹
int GetDirecty()
{
	TCHAR szBuffer[MAX_PATH] = {0}; 
	BROWSEINFO bi; 
	ZeroMemory(&bi,sizeof(BROWSEINFO)); 
	bi.hwndOwner = NULL; 
	bi.pszDisplayName = szBuffer; 
	bi.lpszTitle = _T("从下面选文件夹目录:"); 
	bi.ulFlags = BIF_RETURNFSANCESTORS; 
	LPITEMIDLIST idl = SHBrowseForFolder(&bi); 
	if (NULL == idl) 
	{ 
		return -1; 
	} 
	SHGetPathFromIDList(idl,szBuffer); 
	return 1;
}
int GetFileOrDirecty()
{
	TCHAR szBuffer[MAX_PATH] = {0};   
	BROWSEINFO bi;   
	ZeroMemory(&bi,sizeof(BROWSEINFO));   
	bi.hwndOwner = NULL;   
	bi.pszDisplayName = szBuffer;   
	bi.lpszTitle = _T("从下面选择文件或文件夹:");   
	bi.ulFlags = BIF_BROWSEINCLUDEFILES;   
	LPITEMIDLIST idl = SHBrowseForFolder(&bi);   
	if (NULL == idl)   
	{   
		return -1;   
	}   
	SHGetPathFromIDList(idl,szBuffer);
	return 1;
}