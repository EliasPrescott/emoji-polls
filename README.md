# [Emoji Polls](https://emoji-polls.australorp.dev/)

A toy app I made to play around with Rails 8.

## Notable Files

- [poll_details.rb](./app/controllers/concerns/poll_details.rb)

This file is an example of a slightly more complicated query that is more analytical than a typical CRUD app read query would be.
It should take good advantage of the standard indexes that come built-in with the scaffolding migrations.
To find these indexes, I ran `bin/rails dbconsole` and `.indexes`:

```
sqlite> .indexes
index_option_votes_on_option_id
index_option_votes_on_poll_id
index_option_votes_on_user_id
index_options_on_poll_id
index_options_on_user_id
index_polls_on_user_id
index_sessions_on_user_id
...
```

To see which indexes are actually being used, I grabbed the generated SQL from the server logs and ran explain on it:

```sql
EXPLAIN
SELECT
  options.*,
  user_vote.id AS user_vote_id,
  COUNT(option_votes.id) AS vote_count
FROM "options"
LEFT OUTER JOIN "option_votes" ON "option_votes"."option_id" = "options"."id"
LEFT JOIN (
  SELECT "option_votes".*
  FROM "option_votes"
  WHERE "option_votes"."poll_id" = 5 AND "option_votes"."user_id" = 4
  LIMIT 1
) user_vote ON user_vote.option_id = options.id
WHERE "options"."poll_id" = 5
GROUP BY "options"."id";
```

Side note: trying to read a SQLite query plan reminded my of just how different it is from PostgreSQL and SQL Server.
I knew it had some different design choices just because it's built for very different use cases than the mainstream SQL engines, but trying to read its query plan was like trying to read French as a native English speaker, strangely familiar but mostly gibberish.

After a quick search through the query plan results (I use [vim-dadbod](https://github.com/tpope/vim-dadbod) and [vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui) and you should too), I was able to find that my query hits these three indexes:

```
index_options_on_poll_id
index_option_votes_on_option_id
index_option_votes_on_user_id
```

To be honest, I didn't get a lot of meaningful insight out of the query plan just because I don't have experience optimizing SQLite queries like I do with PostgreSQL.
If anything, it just confirmed that this query has a fairly straightforward execution plan, which is a good sign that it should scale well.

If this application dramatically scaled up in users, it might be good to use [counter_cache](https://guides.rubyonrails.org/association_basics.html#counter-cache) to remove the left join and count on `option_votes`.

I struggled with knowing where to put the `load_show_details` function at first.
I know that Rails relies heavily on auto-loading and it has strong conventions, so I knew there had to be a "blessed" place to put a method that would be shared by multiple controllers.
I settled on making a new concern to hold the method because I found a somewhat recent post online that recommended that.

- [option.rb](./app/models/option.rb)

I'm fairly new to Rails, so I still can't get over how concise the models tend to be.
I'm sure the models in a real battle-hardened application would look a lot different, but I enjoy the trim and tidy look of a freshly-generated model.

The main notable point in `option.rb` is the validation line that <i>attempts</i> to only allow single emoji characters.
I say <i>attempts</i> because it turns out that Unicode emojis can be extremely complicated.
There are multiple emojis that this regex will reject, but trying to make the regex work for all possible emojis would be a nightmare.

At first, I tried to use `^` and `$` to match the beginning and end of the string, but it turns out that's actually not the best way to do it.
When that version of the regex ran, Rails threw this very helpful exception:

```
The provided regular expression is using multiline anchors (^ or $), which may present a security risk. Did you mean to use \A and \z, or forgot to add the :multiline => true option?
```

Since I did not want a multiline regex, I switched to `\A` and `\z`.
With that out of the way, I started looking around for the best way to match emojis.
There are a few packages that try to hide away the ugly details, but eventually I found that you can use `\p{Emoji}` and `\p{Emoji_Modifier}` directly in regex.
Emoji modifier is important because it includes the various color emojis that can be used to set the skin color on the preceding emoji.
For regex implementations that support them, these handy modifiers will match any relevant Unicode code point.
The best way I've found to test these so far is to go to https://regex101.com/ and select the Rust flavor of regex engine.

After matching emojis and emoji modifiers, you also have to worry about [zero-width joiners](https://en.wikipedia.org/wiki/Zero-width_joiner), which allow you to combine any arbitrary Unicode code points into a single "character."
Since there are lots of standardized emojis that use these spacers to join multiple other emojis together, I knew I would have to support multiple pairs of spacers and additional emojis.
After a quick search, it looks like most of the longer emojis should cap out at around 10 code points long, so I picked that as a rough target.
I ended up with `(\u200D\p{Emoji}\p{Emoji_Modifier}?){0,5}` as way of supporting up to 5 zero-width joiners.
Each joiner must be followed by an additional emoji, and may be followed by another emoji modifier.
I haven't actually seen an emoji in the wild that uses multiple emoji modifiers, but I'm sure they exist.

To finish off the regex, I threw in `\uFE0F?` because one emoji I was testing had that at the end.
`\uFE0F` is a [variation selector](https://en.wikipedia.org/wiki/Variation_Selectors_(Unicode_block)) which, as far as I can tell, is used to apply a variation emoji (e.g. the male symbol ♂) to a preceding emoji.
Looking at the Wikipedia article for variation selectors, there's at least one other selector that is valid for emojis that I'm not handling, but my regex is already complicated enough as it is.

If this were a serious, money-making application, I would probably grab the Unicode code point ranges directly and write my own library for parsing out emojis.
It's fun to use a regex because it does a lot of the heavy lifting for me, but I've found that Unicode gets very complicated and you would want a proper, unit-tested library if you were working with emojis for real.
