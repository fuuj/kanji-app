// グローバル変数の creation_id, answer を必要とします.

function msgt(event) {
    var result = 'あなたが選んだのは,' + '[' + event.currentTarget.innerText + ']' + '\n' + '正解です！';
    alert(result);
    (creation_id !== '') ? form(creation_id, 1) : location.reload();
}
function msgf(event) {
    var result = 'あなたが選んだのは,' + '[' + event.currentTarget.innerText + ']' + '不正解です！' + '\n' + '正解は' + answer;
    alert(result);
    (creation_id !== '') ? form(creation_id ,0) : location.reload();
}
function form(creation_id, ox) { //ox->まるばつ(1or0)
    var form = document.createElement('form');
    var request1 = document.createElement('input');
    var request2 = document.createElement('input');

    form.method = 'POST';
    form.action = '/record';

    request1.type = 'hidden'; //入力フォームが表示されないように
    request1.name = 'creation';
    request1.value = creation_id;

    request2.type = 'hidden'; //入力フォームが表示されないように
    request2.name = 'ox';
    request2.value = ox;

    form.appendChild(request1);
    form.appendChild(request2);
    document.body.appendChild(form);

    form.submit();
}
