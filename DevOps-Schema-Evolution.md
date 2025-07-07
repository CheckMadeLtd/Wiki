
- - - - - - - - - - - - - - - - - -  
For important background, first read the section on [Persistence](https://github.com/CheckMadeOrga/CheckMade/wiki/Architecture---Tech---Design-Choices#iii-persistence)!
- - - - - - - - - - - - - - - - - -  

Our Domain Model will naturally evolve our time. It is reflected in both: the 'SQL Schema' and the 'JSON Details Schema' of serialised objects inside the 'details' columns in most tables.

SQL Schema evolution is achieved with a series of sequentially applied sql migrations (sql script files) inside CheckMade.DevOps/scripts/sql/migrations/schema.

JSON Details Schema evolution is naturally represented by changes to the Model classes in the code and thus doesn't require explicit  migration (contrary to the SQL schema).

Either type of evolution may require migrating historic data so that it stays compatible with the Domain Model in the latest versions of CheckMade. Some SQL Schema migrations won't execute at all without first running the corresponding data migration (imagine turning an optional field into a NON NULL field...)

The necessary data migrations themselves are either conducted via SQL statements in CheckMade.DevOps/scripts/sql/migrations/data or, in complicated cases (that require full programming-language expressiveness) via 'run once' C# methods inside the CheckMade.DevOps code base, which can make use of the underlying model classes.

Both, the application of SQL migrations and historic data migrations need to be manually tracked/managed via corresponding tables (csv files) inside CheckMade.DevOps, and are applied per environment (for now just 'Development' and 'Production', we don't currently operate a separate database for 'Staging').

