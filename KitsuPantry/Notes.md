#  Notes

NEXT UP: 
    - Update the label in settings for "show status banner" to make more sense.
    - Recategorize settings.
    - Option: show/hide expired or expiring soon from the alert banner as well.
    

Exists:
    - List of items:
        - Name (String)
        - Location (LocationEntity)
        - Quantity (Double, locked to 8 characters, decimal up to 2 places)
        - Expiration date (Date)
        - Obtained date (Date, can be hidden in settings)
        - Notes (Text block)
    - Add Item button
    - Edit Item (click on line)
    - Delete Item
        - Swipe left to delete
    - Sort
        - Expiration date by default
    - Expiry
        - Border for expired and expiring soon items.
        - Alert bar for expired and expiring soon items.
    - Data persistence
        - CoreData
    - Tabs
        - Default: All, Fridge, Freezer, Pantry.
        - Customizable in options, no repeat names, incl “All”. Prompt if invalid.
        - Limit to 5 additional tabs (outside of “All”), display note if max limit reached.
    - Options
        - Allows adding/removing/renaming of tabs - All is untouchable.
        - Hide “Obtained Date”
        - Expiry
            - Adjustible options for what qualified as "expiring soon"
            - Hide highlighting of expired items
            - Hide highlighting of expiring soon items
            - Hide expired items status banner.
        - 

Todo:
    - Select option
        - Multi-select to delete or move.
    - Options:
        - On delete attempt, pop up to confirm
        - Warning when duplicate item (same name and exp date) added.
        - Hide types of food? (sauce, for example.. reduce clutter.)
        - Turn off “expiring soon” alerts, once implemented.
        - Customize theme colors (i.e. dictionary it.)
    - Filter:
        - Category (Dessert, fruit, ingredient, drink, sauce, etc. Multiple options.)
        - Location. Allow multi-select, and include “Unknown”.
    - Sort:
        - Options. Expiration date, obtained date, incr/decr
            - (Do you want to allow sort by obtained date if toggled off?)
    - Alerts:
            - Send notis when stuff gets close to expiring.
    - Final thing:
        - Set up CloudKit, pay $99 to apple for dev acc, throw it on the store. ^-^


<!--
Consider:
    - Options:
        - Delete button on edit page
        - Turn off date added, if implemented
        - Auto-combine duplicate options instead of warning.
        - Add units (g, cups, lbs, etc), or leave off for default items-only
    - Edit:
        - Exp date: Add a (?) button that displays recommended guesses.
            - And maybe an option to turn that off too.
            - Else maybe put it into the help menu?
    - Title: Kitsupantry instead of location.
    - Add page:
        - Date added (or edited)
    - Chaos mode? 😏
        - Whatever that means..
    - Paid/Premium options:
        - Extra theme selection.
        - Change highlight color of expiring soon/expired items.
        - Pay-what-you-can, with minimum.
        - Fancy theme concepts: Sakura, galaxy, forest, mushroom, kitties, techy
    - Try w/TestFlight later.
    - Look into apple dev student acc -->
