# notes-to-editor

A significant portion of the style guidelines are relevant to my submission. Generally, the dimensions,
palette, and typefaces are pertinent. Since I had a line chart, a scatter chart, and a doughnut chart,
the particular guidelines associated with these chart types are especially relevant. Because it was
an infographic, I needed to globally adhere to colour ordering (for example, if Republican's
are red in one chart, they should be in another). It was also critical to have common title and subtitle spacing and sizing.

To try adhere as closely as possible to the guidelines, I used the `theme_economist` theme from
`ggthemes` as my baseline. I then customised this globally to try be as DRY as possible, though each
chart required their own tweaking.  I'd also like in principle to better package-ize the custom ggplot
code written for re-use in other projects or within this directory for other analyses.

I felt I was able to broadly adhere to the guidelines, namely the palettes, line thicknesses, doughnut
dimensions, chart titling, and axis ticking. I was particularly happy to get the Year-Month x-axis to
resemble several of the example plots with the offset year and only the first year's century specified.
That said, it was exceptionally difficult to perfectly adhere to the guidelines. In particular, I
couldn't find a proper way to download and install the Econ Sans font. Furthermore, because I was
using an infographic and wanted to optimize reproducibility (i.e. not use PhotoShop or InDesign, say),
I used the `patchwork` package in `R`. This was really useful but gave very little control; other
options like `grid` were also very fiddly. The downside was that certain spacing guidelines were
essentially impossible to follow. `ggplot` itself had several limitations which impeded certain more
minor guidelines, such as axis label and title positioning, and facet spacing.

I would love to see how, say, the Economist actually produce their plots, especially their compound
infographics. Of the aforementioned, I would most like to fix the spacing issue while still maintaining
reproducibility. I would also love to figure out how to format the pie/doughnut charts like in the
guidelines because that's one area I felt my submission fell severely short. I also would appreciate
help in giving it some polish; even it might adhere mostly to the guidelines it does feel to be
missing that last bit of shine.
