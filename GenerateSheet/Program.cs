using System.Text;
using GenerateSheet;

foreach (var file in Directory.GetFiles(Environment.CurrentDirectory, "sr_*.csv"))
    processFile(file, 1);

foreach (var file in Directory.GetFiles(Environment.CurrentDirectory, "pp_*.csv"))
    processFile(file, 2);

void processFile(string file, int modsColumn)
{
    StringBuilder processedLines = new StringBuilder();

    using (var sr = new StreamReader(file))
    {
        int lineNum = 0;

        while (sr.Peek() != -1)
        {
            string? line = sr.ReadLine();

            if (string.IsNullOrEmpty(line) || lineNum == 0)
            {
                processedLines.AppendLine(line);
                lineNum++;
                continue;
            }

            string[] parts = line.Split('\t');

            if (int.TryParse(parts[modsColumn], out var intMods))
            {
                parts[modsColumn] = getModString((Mods)intMods);
                line = string.Join('\t', parts);
            }

            processedLines.AppendLine(line);
            lineNum++;
        }
    }

    using (var sw = new StreamWriter(file, false))
        sw.Write(processedLines.ToString());
}

string getModString(Mods mods)
{
    StringBuilder result = new StringBuilder();

    if (mods == Mods.None)
        result.Append("NM");
    if ((mods & Mods.NoFail) > 0)
        result.Append("NF ");
    if ((mods & Mods.Easy) > 0)
        result.Append("EZ ");
    if ((mods & Mods.TouchDevice) > 0)
        result.Append("TD ");
    if ((mods & Mods.Hidden) > 0)
        result.Append("HD ");
    if ((mods & Mods.HardRock) > 0)
        result.Append("HR ");
    if ((mods & Mods.DoubleTime) > 0)
        result.Append("DT ");
    if ((mods & Mods.HalfTime) > 0)
        result.Append("HT ");
    if ((mods & Mods.Flashlight) > 0)
        result.Append("FL ");
    if ((mods & Mods.SpunOut) > 0)
        result.Append("SO ");
    if ((mods & Mods.Key4) > 0)
        result.Append("4K ");
    if ((mods & Mods.Key5) > 0)
        result.Append("5K ");
    if ((mods & Mods.Key6) > 0)
        result.Append("6K ");
    if ((mods & Mods.Key7) > 0)
        result.Append("7K ");
    if ((mods & Mods.Key8) > 0)
        result.Append("8K ");
    if ((mods & Mods.FadeIn) > 0)
        result.Append("FI ");
    if ((mods & Mods.Random) > 0)
        result.Append("RD ");
    if ((mods & Mods.Key9) > 0)
        result.Append("9K ");
    if ((mods & Mods.Mirror) > 0)
        result.Append("MR ");

    return result.ToString().Trim(' ');
}
