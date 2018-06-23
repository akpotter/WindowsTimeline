<!-- saved from url=(0023) https://github.com/kacos2000/WindowsTimeline --> 
#DFIR Windows Timeline 

SQLite query to parse Windows 10 (1803) Timeline's ActivityCache.db

<table>
    <tr>
        <td>
            <img alt="Preview 1" src="Preview1.jpg">
        </td>
        <td>
            <img alt="Preview 2" src="Preview2.jpg">
        </td>
      </tr>
</table>


Tables processed:

- Activities,
- Activity_PackageID,
- ActivityOperation

Either import 'WindowsTimeline.sql' to your SQLite program, or Copy Paste the code to the query window.
Your software needs to support the SQLIte [JSON1 extension] (https://www.sqlite.org/json1.html).

Tested on:
[DB Browser for SQLite] (http://sqlitebrowser.org/),
[SQLiteStudio] (https://sqlitestudio.pl/index.rvt) as well as
[SQLite Expert Pro with the JSON extension] (http://www.sqliteexpert.com/extensions/)

