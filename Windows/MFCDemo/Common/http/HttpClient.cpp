#include "HttpClient.h"

#include <assert.h>
#include <memory>

/**************************************************************************/

HttpClient::HttpClient(const std::wstring& user_agent)
    : m_user_agent(user_agent)
    , m_hSession(NULL)
    , m_hConnect(NULL)
    , m_hRequest(NULL)
{

}

HttpClient::~HttpClient()
{
    http_close();
}

DWORD HttpClient::http_get(const std::wstring& url
                           , const std::vector<std::wstring>& headers, std::string& resp_data)
{
    DWORD ret = request(url, L"GET", headers, std::string(), resp_data);
    http_close();

    return ret;
}

DWORD HttpClient::http_post(const std::wstring& url
                           , const std::vector<std::wstring>& headers, const std::string& body, std::string& resp_data)
{
    DWORD ret = request(url, L"POST", headers, body, resp_data);
    http_close();

    return ret;
}

DWORD HttpClient::http_put(const std::wstring& url
	, const std::vector<std::wstring>& headers, const std::string& body, std::string& resp_data)
{
    DWORD ret = request(url, L"PUT", headers, body, resp_data);
    http_close();

    return ret;
}

void HttpClient::http_close()
{
    if (m_hRequest)
    {
        WinHttpCloseHandle(m_hRequest);
        m_hRequest = NULL;
    }

    if (m_hConnect)
    {
        WinHttpCloseHandle(m_hConnect);
        m_hConnect = NULL;
    }

    if (m_hSession)
    {
        WinHttpCloseHandle(m_hSession);
        m_hSession = NULL;
    }
}

DWORD HttpClient::request(const std::wstring& url, const std::wstring& method
                          , const std::vector<std::wstring>& headers, const std::string& body, std::string& resp_data)
{
    assert(NULL == m_hSession && NULL == m_hConnect && NULL == m_hRequest);

    std::wstring host_name;
    std::wstring url_path;
    URL_COMPONENTS url_comp = {0};
    url_comp.dwStructSize = sizeof(url_comp);

    host_name.resize(url.size());
    url_path.resize(url.size());

    url_comp.lpszHostName      = const_cast<wchar_t*>(host_name.data());
    url_comp.dwHostNameLength  = host_name.size();
    url_comp.lpszUrlPath       = const_cast<wchar_t*>(url_path.data());
    url_comp.dwUrlPathLength   = url_path.size();
    if (FALSE == ::WinHttpCrackUrl(url.c_str(), static_cast<DWORD>(url.size()), 0, &url_comp))
    {
        return ::GetLastError();
    }

	m_hSession = ::WinHttpOpen(m_user_agent.c_str()
        , WINHTTP_ACCESS_TYPE_DEFAULT_PROXY, WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);
    if (NULL == m_hSession)
    {
        return ::GetLastError();
    }

	m_hConnect = ::WinHttpConnect(m_hSession, host_name.c_str(), url_comp.nPort, 0);
    if (NULL == m_hConnect)
    {
        return ::GetLastError();
    }

    DWORD flags = (INTERNET_SCHEME_HTTP == url_comp.nScheme ? 0 : WINHTTP_FLAG_SECURE);
	m_hRequest = ::WinHttpOpenRequest(m_hConnect, method.c_str(), url_path.c_str(),
        NULL, WINHTTP_NO_REFERER, WINHTTP_DEFAULT_ACCEPT_TYPES, flags);
    if (NULL == m_hRequest)
    {
        return ::GetLastError();
    }

    for (std::vector<std::wstring>::const_iterator it = headers.begin(); headers.end() != it; ++it)
    {
        ::WinHttpAddRequestHeaders(m_hRequest, it->c_str(), (ULONG)-1L, WINHTTP_ADDREQ_FLAG_ADD | WINHTTP_ADDREQ_FLAG_COALESCE);
    }

    if (0 == method.compare(L"GET"))
    {
        ::WinHttpSendRequest(m_hRequest, WINHTTP_NO_ADDITIONAL_HEADERS,
            0, WINHTTP_NO_REQUEST_DATA, 0,
            0, 0);
    }
    else if (0 == method.compare(L"POST"))
    {
        const void* body_data = reinterpret_cast<const void*>(body.c_str());
        ::WinHttpSendRequest(m_hRequest, WINHTTP_NO_ADDITIONAL_HEADERS,
            0, const_cast<void*>(body_data), body.size(),
            body.size(), 0);
    }
	else if (0 == method.compare(L"PUT"))
	{
		const void* body_data = reinterpret_cast<const void*>(body.c_str());
		::WinHttpSendRequest(m_hRequest, WINHTTP_NO_ADDITIONAL_HEADERS,
			0, const_cast<void*>(body_data), body.size(),
			body.size(), 0);
	}

    if (ERROR_SUCCESS != ::GetLastError())
    {
        return ::GetLastError();
    }

    if (FALSE == ::WinHttpReceiveResponse(m_hRequest, NULL))
    {
        return ::GetLastError();
    }

    WCHAR status_code[16] = {0};
    DWORD buffer_length = _countof(status_code);
    if (FALSE == ::WinHttpQueryHeaders(m_hRequest, WINHTTP_QUERY_STATUS_CODE
        , WINHTTP_HEADER_NAME_BY_INDEX, status_code, &buffer_length
        , WINHTTP_NO_HEADER_INDEX))
    {
        return ::GetLastError();
    }

    DWORD size = 0;
    while (TRUE == ::WinHttpQueryDataAvailable(m_hRequest, &size))
    {
        if (0 == size)
        {
            break;
        }

        std::unique_ptr<char[]> buffer(new char[size]);
        if (NULL == buffer.get())
        {
            break;
        }

        DWORD lpdwNumberOfBytesRead = 0;
        if (TRUE == ::WinHttpReadData(m_hRequest, buffer.get(), size, &lpdwNumberOfBytesRead))
        {
            resp_data.append(buffer.get(), static_cast<size_t>(lpdwNumberOfBytesRead));
        }
        else
        {
            return ::GetLastError();
        }
    }

	const WCHAR ok_status_code[] = { L'2', L'0', L'0', L'\0' };
	if (0 != ::_wcsicmp(ok_status_code, status_code))
	{
		return EcHttpCodeError;
	}

    return ERROR_SUCCESS;
}
