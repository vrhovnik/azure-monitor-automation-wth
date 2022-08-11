using System;
using System.Windows;
using System.Windows.Interop;
using System.Windows.Media;

namespace TTA.Client.Win.Helpers;

/// <summary>
/// handling hotkeys in WPF
/// </summary>
/// <remarks>
///     code was taken from https://github.com/betsegaw/windowwalker/blob/master/Window%20Walker/Window%20Walker/HotKeyHandler.cs
///     and modified to take shortcut as parameter
/// </remarks>
internal class HotKeyHandler
{
    private IntPtr hwnd;

    /// <summary>
    /// Delegate handler for Hotkey being called
    /// </summary>
    public delegate void HotKeyPressedHandler(object sender, EventArgs e);

    /// <summary>
    /// Event raised when there is an update to the list of open windows
    /// </summary>
    public event HotKeyPressedHandler? OnHotKeyPressed;

    public void RegisterHotKey(Visual window, int modifiers, int key)
    {
        hwnd = new WindowInteropHelper((Window)window).Handle;

        if (PresentationSource.FromVisual(window) is not HwndSource source) 
            throw new Exception("Could not create hWnd source from window.");

        source.AddHook(WndProc);

        InteropAndHelpers.RegisterHotKey(hwnd, 1, modifiers, key);
    }

    /// <summary>
    /// Call back function to detect when the hot key has been called
    /// </summary>
    /// <param name="hwnd"></param>
    /// <param name="msg"></param>
    /// <param name="wParam"></param>
    /// <param name="lParam"></param>
    /// <param name="handled"></param>
    /// <returns></returns>
    private IntPtr WndProc(IntPtr hwnd, int msg, IntPtr wParam, IntPtr lParam, ref bool handled)
    {
        if (msg == 0x0312 && OnHotKeyPressed != null) OnHotKeyPressed(this, EventArgs.Empty);

        return IntPtr.Zero;
    }
}