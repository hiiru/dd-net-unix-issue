// See https://aka.ms/new-console-template for more information

using Datadog.Trace;

Console.WriteLine("App started, periodically tracking metric.");

while (true)
{
    using var scope = Tracer.Instance.StartActive("MainLoop");
    await Task.Delay(1000);
}