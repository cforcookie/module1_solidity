pragma solidity <0.8.9;

contract module1 {
    
    struct user {
        bytes32 login;
        bytes32 password;
        bool admin_status;
        bool seller_status;
        bool buyer_status;
    }
    
    struct worker {
        uint id;
        address magazin;
    }
    
    struct Bank {
        bytes32 login;
        bytes32 password;
    }
    
    struct magazin {
        bytes32 login;
        bytes32 password;
        string city;
        uint[] id_otsiv;
    }
    
    struct Otsiv {
        uint id;
        address giver;
        address magazin;
        string otsiv_user;
        uint grade;
        address[] plus;
        address[] less;
        uint[] id_comments;
    }
    
    struct Comment {
        uint id;
        address giver;
        address magazin;
        string otsiv_user;
        address[] plus;
        address[] less;
    }
    
    struct Application {
        uint id;
        address user;
        address magazin;
        bool change_rule;
        bool status_application;
        bool status_complited;
    }
    
    struct Application_zaim {
        uint id;
        address magazin;
        bool status_application;
        bool status_complited;
        bool returned_status;
    }
    
    address bank = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    
    mapping (address => user) public true_user;
    
    mapping (address => worker) public magazin_worker;
    mapping (address => magazin) public true_magazin;
    mapping (address => bool) public magazin_status;
    mapping (address => uint) public magazin_zaim_id;
    mapping (address => uint) public magazin_comments;
    
    mapping (address => Bank) public true_bank;
    mapping (address => bool) public bank_status;
    
    address[] public workers_list;
    Otsiv[] public otsiv;
    Comment[] public comments;
    Application[] public applications;
    Application_zaim[] public application_zaim;
    
    
    constructor() {
        
    }
    
    function login(bytes32 login, bytes32 password) public view returns(bool) {
        if (true_user[msg.sender].login == login && true_user[msg.sender].password == password) {
            return (true);
        }
        else {
            return (false);
        }
    }
    
    function register_user(bytes32 login, bytes32 password) public {
        require(true_user[msg.sender].login == 0 && true_user[msg.sender].password == 0, "You allready in sytem.");
        true_user[msg.sender] = user(login, password, false, false, true);
    }
    
    function add_worker(address magazin, address user) public {
        require(true_user[msg.sender].admin_status == true, "only admin can change this rule.");
        require(true_user[user].login == 0 && true_user[user].password == 0, "User no register in system");
        require(magazin_status[magazin] == true, "This address is not address magazin.");
        require(magazin_worker[user].magazin != magazin, "User allready work here.");
        uint id = workers_list.length;
        workers_list[id] = user;
        magazin_worker[user] = worker(id, magazin);
        true_user[user].buyer_status = false;
        true_user[user].seller_status = true;
    }
    
    function add_worker_from_application(uint id_application) public {
        require(true_user[msg.sender].admin_status == true, "only admin can change this rule.");
        require(applications[id_application].status_application == true && applications[id_application].status_complited == false, "This application is end.");
        if (applications[id_application].change_rule == true) {
            uint id_user = workers_list.length;
            workers_list[id_user] = applications[id_application].user;
            magazin_worker[applications[id_application].user] = worker(id_user, applications[id_application].magazin);
            true_user[applications[id_application].user].buyer_status = false;
            true_user[applications[id_application].user].seller_status = true;
            applications[id_application].status_application == false;
            applications[id_application].status_complited == true;
        }
        else {
            true_user[applications[id_application].user].seller_status = false;
            true_user[applications[id_application].user].buyer_status = true;
            applications[id_application].status_application == false;
            applications[id_application].status_complited == true;
            
            delete workers_list[magazin_worker[applications[id_application].user].id];
            delete magazin_worker[applications[id_application].user];
        }
    }
    
    function create_application(address magazin, bool up_or_down) public {
        require(true_user[msg.sender].login != 0 && true_user[msg.sender].password != 0, "You not allready in sytem.");
        require(magazin_status[magazin] == true, "This address is not address magazin.");
        require(magazin_worker[msg.sender].magazin != magazin, "You allready work here.");
        require(get_view_application(msg.sender, magazin) == false, "You allready create this application.");
        applications.push(Application(applications.length, msg.sender, magazin, up_or_down, true, false));
        
    }
    
    function chanle_application(uint id) public {
        require(applications[id].user == msg.sender, "This is not your application.");
        require(applications[id].status_application == true && applications[id].status_complited == false, "This application is end.");
        applications[id].status_application = false;
    }
    
    function get_view_application(address user, address magazin) private view returns(bool) {
        for (uint i = 0; i < applications.length; i++) {
            if (applications[i].user == user && applications[i].magazin == magazin && applications[i].status_application == true) {
                return(true);
            }
            else {
                continue;
            }
        }
        return (false);
    }
    
    function new_magazin(address magazin_address, string memory city, bool zaim_anser) public {
        require(true_user[msg.sender].admin_status == true, "only admin can add new magazin.");
        require(true_user[magazin_address].login != 0 && true_user[magazin_address].password != 0, "User not allready in sytem.");
        require(magazin_status[magazin_address] == false, "Magazin allready in system.");
        uint[] memory id_otsiv;
        true_magazin[magazin_address] = magazin(true_user[magazin_address].login, true_user[magazin_address].password, city, id_otsiv);
        magazin_status[magazin_address] = true;
        if (zaim_anser == true) {
            uint id_zaim = application_zaim.length;
            application_zaim.push(Application_zaim(id_zaim, magazin_address, true, false, false));
            magazin_zaim_id[magazin_address] = id_zaim;
        }
    }
    
    function delete_magazin(address magazin) public {
        require(magazin_status[magazin] == true, "This is not magazin.");
        require(magazin_zaim_id[magazin] == 0, "Magazin have non returned zaim.");
        for (uint i = 0; i < workers_list.length; i++) {
            if (magazin_worker[workers_list[i]].magazin == magazin) {
                true_user[workers_list[i]].seller_status = false;
                true_user[workers_list[i]].buyer_status = true;
                delete magazin_worker[workers_list[i]];
                delete workers_list[i];
            }
            else {
                continue;
            }
        }
        delete true_magazin[magazin];
        delete magazin_status[magazin];
        
    } 
    
    function create_zaim() public {
        require(magazin_status[msg.sender] == true, "Only magazins can create zaim.");
        require(magazin_zaim_id[msg.sender] == 0, "You have non returned zaim.");
        uint id_zaim = application_zaim.length;
        application_zaim.push(Application_zaim(id_zaim, msg.sender, true, false, false));
        magazin_zaim_id[msg.sender] = id_zaim;
    }
    
    function chanle_zaim() public {
        require(application_zaim[magazin_zaim_id[msg.sender]].magazin == msg.sender, "No you create this application.");
        require(application_zaim[magazin_zaim_id[msg.sender]].status_application == true && application_zaim[magazin_zaim_id[msg.sender]].status_complited == false && application_zaim[magazin_zaim_id[msg.sender]].returned_status == false);
        delete application_zaim[magazin_zaim_id[msg.sender]];
        delete magazin_zaim_id[msg.sender];
    }
    
    function zaim_magazin(uint id) public payable {
        require(application_zaim[id].status_application == true, "Application not created.");
        require(application_zaim[id].status_complited == false, "Application allready gived.");
        require(view_value() == true, "Value less.");
        payable(applications[id].magazin).transfer(msg.value);
    }
    
    function view_value() private view returns(bool) {
        if (msg.value == 10*10**18) {
            return (true);
        }
        else (false);
    }
    
    function give_otsiv(address magazin, uint grade, string memory comment, bool plus_or_less) public {
        require(magazin_status[magazin] == true, "This is not magazin address.");
        require(grade <= 10 && grade >= 0, "You gived non correct grade.");
        uint id = otsiv.length;
        address[] memory plus;
        address[] memory less;
        uint[] memory id_comments;
        if (plus_or_less == true) {
            plus[plus.length] = msg.sender;
            otsiv.push(Otsiv(id, msg.sender, magazin, comment, grade, plus, less, id_comments));
        }
        else {
            less[id] = msg.sender;
            otsiv.push(Otsiv(id, msg.sender, magazin, comment, grade, plus, less, id_comments));
        }
        true_magazin[magazin].id_otsiv.push(id);
        
    }
    
    function give_comment(uint id_otsiv, string memory comment, bool plus_or_less) public {
        uint id = comments.length;
        address[] memory plus;
        address[] memory less;
        if (plus_or_less == true) {
            plus[plus.length] = msg.sender;
        }
        else {
            plus[less.length] = msg.sender;
        }
        comments.push(Comment(id, msg.sender, otsiv[id_otsiv].magazin, comment, plus, less));
        otsiv[id_otsiv].id_comments.push(id);
    }
    
    function give_plus_or_less(bool otsiv_or_comment, bool plus_or_less, uint id) public {
        require(view_get_anser(otsiv_or_comment, id) == true, "You allready give it.");
        if (otsiv_or_comment == true) {
            if (plus_or_less == true) {
                otsiv[id].plus.push(msg.sender);
            }
            else {
                otsiv[id].less.push(msg.sender);
            }
        }
        else {
            if (plus_or_less == true) {
                comments[id].plus.push(msg.sender);
            }
            else {
                comments[id].less.push(msg.sender);
            }
        }
    }
    
    function return_plus_or_less(bool otsiv_or_comment, uint id) public {
        require(serch_anser(otsiv_or_comment, id) == true, "You not give plus or less this.");
        uint i = serch_id(otsiv_or_comment, id);
        if (otsiv_or_comment == true) {
            if (serch_plus_or_less( otsiv_or_comment, id) == true) {
                delete otsiv[id].plus[i];
            }
            else {
                delete otsiv[id].less[i];
            }
        }
        else {
            if (serch_plus_or_less( otsiv_or_comment, id) == true) {
                delete comments[id].plus[i];
            }
            else {
                delete comments[id].less[i];
            }
        }
    }
    
    function serch_plus_or_less(bool otsiv_or_comment, uint id) private view returns(bool) {
        if (otsiv_or_comment == true) {
            for (uint i = 0; i < otsiv[id].plus.length || i < otsiv[id].less.length; i++) {
                if (otsiv[id].plus[i] == msg.sender) {
                    return(true);
                }
                else if (otsiv[id].less[i] == msg.sender) {
                    return(false);
                }
            }
        }
        else if (otsiv_or_comment == false) {
            for (uint i = 0; i < comments[id].plus.length || i < comments[id].less.length; i++) {
                if (comments[id].plus[i] == msg.sender) {
                    return(true);
                }
                else if (comments[id].less[i] == msg.sender) {
                    return(false);
                }
            }
        }
    }
    
    function serch_anser(bool otsiv_or_comment, uint id) private view returns(bool) {
        if (otsiv_or_comment == true) {
            for (uint i = 0; i < otsiv[id].plus.length || i < otsiv[id].less.length; i++) {
                if (otsiv[id].plus[i] == msg.sender) {
                    return(true);
                }
                else if (otsiv[id].less[i] == msg.sender) {
                    return(true);
                }
            }
            return(false);
        }
        else if (otsiv_or_comment == false) {
            for (uint i = 0; i < comments[id].plus.length || i < comments[id].less.length; i++) {
                if (comments[id].plus[i] == msg.sender) {
                    return(true);
                }
                else if (comments[id].less[i] == msg.sender) {
                    return(true);
                }
            }
            return(false);
        }
    }
    
    function serch_id(bool otsiv_or_comment, uint id) private view returns(uint) {
        if (otsiv_or_comment == true) {
            for (uint i = 0; i < otsiv[id].plus.length || i < otsiv[id].less.length; i++) {
                if (otsiv[id].plus[i] == msg.sender) {
                    return(i);
                }
                else if (otsiv[id].less[i] == msg.sender) {
                    return(i);
                }
            }

        }
        else if (otsiv_or_comment == false) {
            for (uint i = 0; i < comments[id].plus.length || i < comments[id].less.length; i++) {
                if (comments[id].plus[i] == msg.sender) {
                    return(i);
                }
                else if (comments[id].less[i] == msg.sender) {
                    return(i);
                }
            }
        }
    }
    
    function view_get_anser(bool otsiv_or_comment, uint id) private view returns(bool){
        if (otsiv_or_comment == true) {
            for (uint i = 0; i < otsiv[id].plus.length || i < otsiv[id].less.length; i++) {
                if (otsiv[id].plus[i] == msg.sender) {
                    return(false);
                }
                else if (otsiv[id].less[i] == msg.sender) {
                    return(false);
                }
            }
            return(true);
        }
        else if (otsiv_or_comment == false) {
            for (uint i = 0; i < comments[id].plus.length || i < comments[id].less.length; i++) {
                if (comments[id].plus[i] == msg.sender) {
                    return(false);
                }
                else if (comments[id].less[i] == msg.sender) {
                    return(false);
                }
            }
            return(true);
        }   
    }
}
