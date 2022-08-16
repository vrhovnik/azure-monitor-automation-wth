using System;
using System.Globalization;
using System.Windows.Data;
using TTA.Core;

namespace TTA.Client.Win.Helpers;

public class TruncateConverter : IValueConverter
{
    public object Convert(object value, Type targetType, object parameter, CultureInfo culture) => 
        value.ToString().Truncate(30);

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
    {
        throw new NotImplementedException();
    }
}