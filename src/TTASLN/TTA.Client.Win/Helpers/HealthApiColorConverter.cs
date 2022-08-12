using System;
using System.ComponentModel;
using System.Globalization;
using System.Windows.Data;
using System.Windows.Media;

namespace TTA.Client.Win.Helpers;

public class HealthApiColorConverter : IValueConverter
{
    public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
    {
        if (value is not bool isHealthy) return Brushes.LightYellow;

        try
        {
            return isHealthy ? Brushes.Green : Brushes.LightGray;
        }
        catch (FormatException e)
        {
            throw new FormatException("Cannot convert from boolean to brush");
        }
    }

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
    {
        throw new NotImplementedException();
    }
}