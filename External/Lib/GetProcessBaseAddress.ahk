GetProcessBaseAddress()
{
   WinGet, WindowHandle, ID
   return DllCall(A_PtrSize = 4 ? "GetWindowLong" : "GetWindowLongPtr", "Ptr", WindowHandle, "Int", -6, "Ptr")
}
