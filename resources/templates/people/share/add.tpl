<div-async name="settings-$(personId)">
    <h2><personName/></h2>
    <a-async href="/people/$(personId)/show">/\ add a share</a-async><br>
    <form-async action="/people/$(personId)/share/add" method="POST">
      <table>
        <tr><td colspan="2"><date-errors><error/><br></date-errors></td></tr>
        <tr>
          <td class="label"><label for="date">date:</label></td> 
          <td><input name="date" type="text" value="$(date-value)" /></td></tr>
          <tr><td colspan="2"><share-errors><error/><br></share-errors></td></tr>
          <tr>
            <td class="label"><label for="share">share:</label></td> 
            <td><input name="share" type="text" value="$(share-value)" />
          <button type="submit" title=""/></td></tr>
      </table>
    </form-async>
</div-async>
