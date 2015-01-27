<div class="row">

    <div class="col-lg-11 col-sm-10">

        {switch match=$edit_warning}
        {case match=1}
        <div class="alert alert-warning">
        <h4><span class="time">[{currentdate()|l10n( shortdatetime )}]</span> {'Version is not a draft'|i18n( 'design/standard/content/history' )}</h4>
        <ul>
            <li>{'Version %1 is not available for editing anymore. Only drafts can be edited.'|i18n( 'design/standard/content/history',, array( $edit_version ) )}</li>
            <li>{'To edit this version, first create a copy of it.'|i18n( 'design/standard/content/history' )}</li>
        </ul>
        </div>
        {/case}
        {case match=2}
        <div class="alert alert-warning">
        <h4><span class="time">[{currentdate()|l10n( shortdatetime )}]</span> {'Version is not yours'|i18n( 'design/standard/content/history' )}</h4>
        <ul>
            <li>{'Version %1 was not created by you. You can only edit your own drafts.'|i18n( 'design/standard/content/history',, array( $edit_version ) )}</li>
            <li>{'To edit this version, first create a copy of it.'|i18n( 'design/standard/content/history' )}</li>
        </ul>
        </div>
        {/case}
        {case match=3}
        <div class="alert alert-warning">
        <h4><span class="time">[{currentdate()|l10n( shortdatetime )}]</span> {'Unable to create new version'|i18n( 'design/standard/content/history' )}</h4>
        <ul>
            <li>{'Version history limit has been exceeded and no archived version can be removed by the system.'|i18n( 'design/standard/content/history' )}</li>
            <li>{'You can change your version history settings in content.ini, remove draft versions or edit existing drafts.'|i18n( 'design/standard/content/history' )}</li>
        </ul>
        </div>
        {/case}
        {case}
        {/case}
        {/switch}


        {def $page_limit=30
             $list_count=fetch(content,version_count, hash(contentobject, $object))}

        <form name="versionsform" action={concat( '/content/history/', $object.id, '/' )|ezurl} method="post">

        <div class="box">
            <div class="box-header" data-original-title>
                <h2>{'Versions for <%object_name> [%version_count]'|i18n( 'design/standard/content/history',, hash( '%object_name', $object.name, '%version_count', $list_count ) )|wash}</h2>
            </div>
            <div class="box-content">

                {if $list_count}
                <table class="table table-condensed" cellspacing="0">
                <tr>
                    <th class="tight"></th>
                    <th>{'Version'|i18n( 'design/standard/content/history' )}</th>
                    <th>{'Status'|i18n( 'design/standard/content/history' )}</th>
                    <th>{'Modified translation'|i18n( 'design/standard/content/history' )}</th>
                    <th>{'Creator'|i18n( 'design/standard/content/history' )}</th>
                    <th>{'Created'|i18n( 'design/standard/content/history' )}</th>
                    <th>{'Modified'|i18n( 'design/standard/content/history' )}</th>
                    <th class="tight">&nbsp;</th>
                    <th class="tight">&nbsp;</th>
                </tr>


                {foreach fetch( content, version_list, hash( contentobject, $object, limit, $page_limit, offset, $view_parameters.offset ) ) as $version
                    sequence array( bglight, bgdark ) as $seq
                }

                {def $initial_language = $version.initial_language}
                <tr class="{$seq}">

                    {* Remove. *}
                    <td>
                        {if and($version.can_remove,or( eq( $version.status, 0 ),eq( $version.status, 3), eq( $version.status, 4 ) ))}
                            <input type="checkbox" name="DeleteIDArray[]" value="{$version.id}" title="{'Select version #%version_number for removal.'|i18n( 'design/standard/content/history',, hash( '%version_number', $version.version ) )}" />
                        {else}
                            <input type="checkbox" name="" value="" disabled="disabled" title="{'Version #%version_number cannot be removed because it is either the published version of the object or because you do not have permission to remove it.'|i18n( 'design/standard/content/history',, hash( '%version_number', $version.version ) )}" />
                        {/if}
                    </td>

                    {* Version/view. *}
                    <td><a href={concat( '/content/versionview/', $object.id, '/', $version.version, '/', $initial_language.locale )|ezurl} title="{'View the contents of version #%version_number. Translation: %translation.'|i18n( 'design/standard/content/history',, hash( '%version_number', $version.version, '%translation', $initial_language.name ) )}">{$version.version}</a></td>

                    {* Status. *}
                    <td>{$version.status|choose( 'Draft'|i18n( 'design/standard/content/history' ), 'Published'|i18n( 'design/standard/content/history' ), 'Pending'|i18n( 'design/standard/content/history' ), 'Archived'|i18n( 'design/standard/content/history' ), 'Rejected'|i18n( 'design/standard/content/history' ), 'Untouched draft'|i18n( 'design/standard/content/history' ) )}</td>

                    {* Modified translation. *}
                    <td>
                        <img src="{$initial_language.locale|flag_icon}" alt="{$initial_language.locale}" />&nbsp;<a href={concat('/content/versionview/', $object.id, '/', $version.version, '/', $initial_language.locale, '/' )|ezurl} title="{'View the contents of version #%version_number. Translation: %translation.'|i18n( 'design/standard/content/history',, hash( '%translation', $initial_language.name, '%version_number', $version.version ) )}" >{$initial_language.name|wash}</a>
                    </td>

                    {* Creator. *}
                    <td>{$version.creator.name|wash}</td>

                    {* Created. *}
                    <td>{$version.created|l10n( shortdatetime )}</td>

                    {* Modified. *}
                    <td>{$version.modified|l10n( shortdatetime )}</td>

                    {* Copy button. *}
                    <td align="right" class="right">
                    {def $can_edit_lang = 0}
                    {foreach $object.can_edit_languages as $edit_language}
                        {if eq( $edit_language.id, $initial_language.id )}
                        {set $can_edit_lang = 1}
                        {/if}
                    {/foreach}

                        {if and( $can_edit, $can_edit_lang )}
                            <input type="hidden" name="CopyVersionLanguage[{$version.version}]" value="{$initial_language.locale}" />
                            <input type="image" src={'copy.gif'|ezimage} name="HistoryCopyVersionButton[{$version.version}]" value="" title="{'Create a copy of version #%version_number.'|i18n( 'design/standard/content/history',, hash( '%version_number', $version.version ) )}" />
                        {else}
                            <input type="image" src={'copy-disabled.gif'|ezimage} name="" value="" disabled="disabled" title="{'You cannot make copies of versions because you do not have permission to edit the object.'|i18n( 'design/standard/content/history' )}" />
                        {/if}
                    {undef $can_edit_lang}
                    </td>

                    {* Edit button. *}
                    <td>
                        {if and( array(0, 5)|contains($version.status), $version.creator_id|eq( $user_id ), $can_edit ) }
                            <input type="image" src={'edit.gif'|ezimage} name="HistoryEditButton[{$version.version}]" value="" title="{'Edit the contents of version #%version_number.'|i18n( 'design/standard/content/history',, hash( '%version_number', $version.version ) )}" />
                        {else}
                            <input type="image" src={'edit-disabled.gif'|ezimage} name="HistoryEditButton[{$version.version}]" value="" disabled="disabled" title="{'You cannot edit the contents of version #%version_number either because it is not a draft or because you do not have permission to edit the object.'|i18n( 'design/standard/content/history',, hash( '%version_number', $version.version ) )}" />
                        {/if}
                    </td>

                </tr>
                {undef $initial_language}
                {/foreach}
                </table>
                {else}

                    <p>{'This object does not have any versions.'|i18n( 'design/standard/content/history' )}</p>

                {/if}

                {include name=navigator
                         uri='design:navigator/google.tpl'
                         page_uri=concat( '/content/history/', $object.id, '///' )
                         item_count=$list_count
                         view_parameters=$view_parameters
                         item_limit=$page_limit}



                <input class="btn" type="submit" name="RemoveButton" value="{'Remove selected'|i18n( 'design/standard/content/history' )}" title="{'Remove the selected versions from the object.'|i18n( 'design/standard/content/history' )}" />
                <input type="hidden" name="DoNotEditAfterCopy" value="" />

                {if $object.can_diff}
                {def $languages=$object.languages}
                <form action={concat( $module.functions.history.uri, '/', $object.id, '/' )|ezurl} method="post">
                        <select name="Language">
                            {foreach $languages as $lang}
                                <option value="{$lang.locale}">{$lang.name|wash}</option>
                            {/foreach}
                        </select>
                        <select name="FromVersion">
                            {foreach $object.versions as $ver}
                                <option {if eq( $ver.version, $selectOldVersion)}selected="selected"{/if} value="{$ver.version}">{$ver.version|wash}</option>
                            {/foreach}
                        </select>
                        <select name="ToVersion">
                            {foreach $object.versions as $ver}
                                <option {if eq( $ver.version, $selectNewVersion)}selected="selected"{/if} value="{$ver.version}">{$ver.version|wash}</option>
                            {/foreach}
                        </select>
                    <input type="hidden" name="ObjectID" value="{$object.id}" />
                    <input class="btn" type="submit" name="DiffButton" value="{'Show differences'|i18n( 'design/standard/content/history' )}" />
                </form>
                {/if}

            </div>
        </div>


        {if and( is_set( $object ), is_set( $diff ), is_set( $oldVersion ), is_set( $newVersion ) )|not}
        <div class="box">
            <div class="box-header" data-original-title>
                <h2>{'Published version'|i18n( 'design/standard/content/history' )}</h2>
            </div>
            <div class="box-content">

                <table class="table table-condensed" cellspacing="0">
                <tr>
                    <th>{'Version'|i18n( 'design/standard/content/history' )}</th>
                    <th>{"Translations"|i18n("design/standard/content/history")}</th>
                    <th>{'Creator'|i18n( 'design/standard/content/history' )}</th>
                    <th>{'Created'|i18n( 'design/standard/content/history' )}</th>
                    <th>{'Modified'|i18n( 'design/standard/content/history' )}</th>
                    <th class="tight">{'Copy translation'|i18n( 'design/standard/content/history' )}</th>
                    <th class="tight">&nbsp;</th>
                </tr>

                {def $published_item=$object.current
                     $initial_language = $published_item.initial_language}
                <tr>

                    {* Version/view. *}
                    <td><a href={concat( '/content/versionview/', $object.id, '/', $published_item.version, '/', $initial_language.locale )|ezurl} title="{'View the contents of version #%version_number. Translation: %translation.'|i18n( 'design/standard/content/history',, hash( '%version_number', $published_item.version, '%translation', $initial_language.name ) )}">{$published_item.version}</a></td>

                    {* Translations *}
                    <td>
                        {foreach $published_item.language_list as $lang}
                            {delimiter}<br />{/delimiter}
                            <img src="{$lang.language_code|flag_icon}" alt="{$lang.language_code|wash}" />&nbsp;
                            <a href={concat("/content/versionview/",$object.id,"/",$published_item.version,"/",$lang.language_code,"/")|ezurl}>{$lang.locale.intl_language_name|wash}</a>
                        {/foreach}
                    </td>

                    {* Creator. *}
                    <td>{$published_item.creator.name|wash}</td>

                    {* Created. *}
                    <td>{$published_item.created|l10n( shortdatetime )}</td>

                    {* Modified. *}
                    <td>{$published_item.modified|l10n( shortdatetime )}</td>

                    {* Copy translation list. *}
                    <td align="right" class="right">
                        <select name="CopyVersionLanguage[{$published_item.version}]">
                            {foreach $published_item.language_list as $lang_list}
                                <option value="{$lang_list.language_code}"{if $lang_list.language_code|eq($published_item.initial_language.locale)} selected="selected"{/if}>{$lang_list.locale.intl_language_name|wash}</option>
                            {/foreach}
                        </select>
                    </td>

                    {* Copy button *}
                    <td>
                        {def $can_edit_lang = 0}
                        {foreach $object.can_edit_languages as $edit_language}
                            {if eq( $edit_language.id, $initial_language.id )}
                            {set $can_edit_lang = 1}
                            {/if}
                        {/foreach}

                        {if and( $can_edit, $can_edit_lang )}
                            <input type="image" src={'copy.gif'|ezimage} name="HistoryCopyVersionButton[{$published_item.version}]" value="" title="{'Create a copy of version #%version_number.'|i18n( 'design/standard/content/history',, hash( '%version_number', $published_item.version ) )}" />
                        {else}
                            <input type="image" src={'copy-disabled.gif'|ezimage} name="" value="" disabled="disabled" title="{'You cannot make copies of versions because you do not have permission to edit the object.'|i18n( 'design/standard/content/history' )}" />
                        {/if}
                        {undef $can_edit_lang}
                    </td>

                </tr>
                {undef $initial_language}
                </table>
            </div>
        </div>

        <div class="box">
            <div class="box-header" data-original-title>
                <h2>{'New drafts [%newerDraftCount]'|i18n( 'design/standard/content/history',, hash( '%newerDraftCount', $newerDraftVersionListCount ) )}</h2>
            </div>
            <div class="box-content">

                {if $newerDraftVersionList|count|ge(1)}
                <table class="table table-condensed" cellspacing="0">
                <tr>
                    <th>{'Version'|i18n( 'design/standard/content/history' )}</th>
                    <th>{'Modified translation'|i18n( 'design/standard/content/history' )}</th>
                    <th>{'Creator'|i18n( 'design/standard/content/history' )}</th>
                    <th>{'Created'|i18n( 'design/standard/content/history' )}</th>
                    <th>{'Modified'|i18n( 'design/standard/content/history' )}</th>
                    <th class="tight">&nbsp;</th>
                    <th class="tight">&nbsp;</th>
                </tr>

                {foreach $newerDraftVersionList as $draft_version
                    sequence array( bglight, bgdark ) as $seq}
                {def $initial_language = $draft_version.initial_language}
                <tr class="{$seq}">

                    {* Version/view. *}
                    <td><a href={concat( '/content/versionview/', $object.id, '/', $draft_version.version, '/', $initial_language.locale )|ezurl} title="{'View the contents of version #%version_number. Translation: %translation.'|i18n( 'design/standard/content/history',, hash( '%version_number', $draft_version.version, '%translation', $initial_language.name ) )}">{$draft_version.version}</a></td>

                    {* Modified translation. *}
                    <td>
                        <img src="{$initial_language.locale|flag_icon}" alt="{$initial_language.locale}" />&nbsp;<a href={concat('/content/versionview/', $object.id, '/', $draft_version.version, '/', $initial_language.locale, '/' )|ezurl} title="{'View the contents of version #%version_number. Translation: %translation.'|i18n( 'design/standard/content/history',, hash( '%translation', $initial_language.name, '%version_number', $draft_version.version ) )}" >{$initial_language.name|wash}</a>
                    </td>

                    {* Creator. *}
                    <td>{$draft_version.creator.name|wash}</td>

                    {* Created. *}
                    <td>{$draft_version.created|l10n( shortdatetime )}</td>

                    {* Modified. *}
                    <td>{$draft_version.modified|l10n( shortdatetime )}</td>

                    {* Copy button. *}
                    <td align="right" class="right">
                    {def $can_edit_lang = 0}
                    {foreach $object.can_edit_languages as $edit_language}
                        {if eq( $edit_language.id, $initial_language.id )}
                        {set $can_edit_lang = 1}
                        {/if}
                    {/foreach}

                        {if and( $can_edit, $can_edit_lang )}
                            <input type="hidden" name="CopyVersionLanguage[{$draft_version.version}]" value="{$initial_language.locale}" />
                            <input type="image" src={'copy.gif'|ezimage} name="HistoryCopyVersionButton[{$draft_version.version}]" value="" title="{'Create a copy of version #%version_number.'|i18n( 'design/standard/content/history',, hash( '%version_number', $draft_version.version ) )}" />
                        {else}
                            <input type="image" src={'copy-disabled.gif'|ezimage} name="" value="" disabled="disabled" title="{'You cannot make copies of versions because you do not have permission to edit the object.'|i18n( 'design/standard/content/history' )}" />
                        {/if}
                    {undef $can_edit_lang}
                    </td>

                    {* Edit button. *}
                    <td>
                        {if and( array(0, 5)|contains($draft_version.status), $draft_version.creator_id|eq( $user_id ), $can_edit ) }
                            <input type="image" src={'edit.gif'|ezimage} name="HistoryEditButton[{$draft_version.version}]" value="" title="{'Edit the contents of version #%version_number.'|i18n( 'design/standard/content/history',, hash( '%version_number', $draft_version.version ) )}" />
                        {else}
                            <input type="image" src={'edit-disabled.gif'|ezimage} name="HistoryEditButton[{$draft_version.version}]" disabled="disabled" value="" title="{'You cannot edit the contents of version #%version_number either because it is not a draft or because you do not have permission to edit the object.'|i18n( 'design/standard/content/history',, hash( '%version_number', $draft_version.version ) )}" />
                        {/if}
                    </td>

                </tr>
                {undef $initial_language}
                {/foreach}
                </table>
                {else}
                <div class="block">
                    <p>{'This object does not have any drafts.'|i18n( 'design/standard/content/history' )}</p>
                </div>
                {/if}

            </div>
        </div>

        {elseif and( is_set( $object ), is_set( $diff ), is_set( $oldVersion ), is_set( $newVersion ) )}

        <div class="box">
            <div class="box-header" data-original-title>
                <h2>{'Differences between versions %oldVersion and %newVersion'|i18n( 'design/standard/content/history',, hash( '%oldVersion', $oldVersion, '%newVersion', $newVersion ) )}</h2>
            </div>
            <div class="box-content">

                {literal}
                <script type="text/javascript">
                function show( element, method )
                {
                    document.getElementById( element ).className = method;
                }
                </script>
                {/literal}

                <div id="diffview">

                <script type="text/javascript">
                document.write('<div class="context-toolbar"><div class="block"><ul><li><a href="#" onclick="show(\'diffview\', \'previous\'); return false;">{'Old version'|i18n( 'design/standard/content/history' )}</a></li><li><a href="#" onclick="show(\'diffview\', \'inlinechanges\'); return false;">{'Inline changes'|i18n( 'design/standard/content/history' )}</a></li><li><a href="#" onclick="show(\'diffview\', \'blockchanges\'); return false;">{'Block changes'|i18n( 'design/standard/content/history' )}</a></li><li><a href="#" onclick="show(\'diffview\', \'latest\'); return false;">{'New version'|i18n( 'design/standard/content/history' )}</a></li></ul></div></div>');
                </script>

                {foreach $object.data_map as $attr}
                <div class="block">
                <label>{$attr.contentclass_attribute.name}:</label>
                <div class="attribute-view-diff">
                        {attribute_diff_gui view=diff attribute=$attr old=$oldVersion new=$newVersion diff=$diff[$attr.contentclassattribute_id]}
                </div>
                </div>
                {/foreach}

                </div>


                <form action={concat( '/content/history/', $object.id, '/' )|ezurl} method="post">
                <input class="btn" type="submit" value="{'Back to history'|i18n( 'design/standard/content/history' )}" />
                </form>

            </div>
        </div>
        </form>
        {/if}
    </div>

    <div class="col-lg-1 col-sm-2">
        <ul class="actions-nav">
            <li>
                <a href="#" onclick="ezpopmenu_submitForm( 'versionsback' ); return false;">
                    <i class="fa fa-times"></i>
                    <p>{'Back'|i18n( 'design/standard/content/history' )}</p>
                </a>
            </li>
        </ul>
        <form name="versionsback" action={concat( '/content/history/', $object.id, '/' )|ezurl} method="post" id="versionsback">
            {if is_set( $redirect_uri )}
                <input class="text" type="hidden" name="RedirectURI" value="{$redirect_uri}" />
            {/if}
            <input type="hidden" name="BackButton"  />
        </form>
    </div>
</div>